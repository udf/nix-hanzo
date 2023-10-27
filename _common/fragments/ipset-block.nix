{ config, lib, pkgs, options, ... }:
with lib;
let
  cfg = config.custom.ipset-block;
  ipsetName = "badnets";
  bannedASNs = [
    "4134" # CHINANET-BACKBONE No.31,Jin-rong Street, CN
    "4837" # CHINA169-BACKBONE CHINA UNICOM China169 Backbone, CN
    "9009" # M247, RO
    "9232" # NTTE-AS Ntte Global Network Brand Name, HK
    "9808" # CHINAMOBILE-CN China Mobile Communications Group Co., Ltd., CN
    "14061" # DIGITALOCEAN-ASN, US
    "16276" # OVH, FR
    "16509" # AMAZON-02, US
    "19318" # IS-AS-1, US
    "20473" # AS-CHOOPA, US
    "21859" # ZEN-ECN, US
    "25820" # IT7NET, CA
    "38186" # FTG-AS-AP Forewin Telecom Group Limited, ISP at, HK
    "49901" # KUIPER-AS, GB
    "50867" # HOSTKEY-RU-AS, NL
    "51167" # CONTABO, DE
    "51852" # PLI-AS, PA
    "55933" # CLOUDIE-AS-AP Cloudie Limited, HK
    "56380" # AS-ITFRUIT, MD
    "57043" # HOSTKEY-AS, NL
    "57523" # CHANGWAY-AS, HK
    "57678" # CATTECHNOLOGIES-AS, HK
    "58061" # SCALAXY-AS, LV
    "58461" # CT-HANGZHOU-IDC No.288,Fu-chun Road, CN
    "61432" # VAIZ-AS ITBks892, UA
    "63949" # AKAMAI-LINODE-AP Akamai Connected Cloud, SG
    "132203" # TENCENT-NET-AP-CN Tencent Building, Kejizhongyi Avenue, CN
    "135377" # UCLOUD-HK-AS-AP UCLOUD INFORMATION TECHNOLOGY HK LIMITED, HK
    "135636" # RACKH-AS-AP Rackh Lintas Asia, pt, ID
    "136180" # IPIP-CN Beijing Tiantexin Tech. Co., Ltd., CN
    "138968" # RAINBOWIDC-AS-AP rainbow network limited, JP
    "148981" # CHINANET-HUBEI-SHIYAN-IDC China Telecom, CN
    "150706" # HKZTCL-AS-AP Hong Kong Zhengxing Technology Co., Ltd., HK
    "201814" # MEVSPACE, PL
    "202425" # INT-NETWORK, SC
    "202685" # AS-PFCLOUD, GB
    "207812" # DM_AUTO, BG
    "208091" # XHOST-INTERNET-SOLUTIONS, GB
    "209588" # FLYSERVERS-ASN, PA
    "209605" # HOSTBALTIC, LT
    "211619" # MAXKO, HR
    "211680" # AS-BITSIGHT, PT
    "212482" # XHOST-INTERNET-SOLUTIONS, GB
    "216354" # MISAKAF-NET, GB
    "396982" # GOOGLE-CLOUD-PLATFORM, US
    "398324" # CENSYS-ARIN-01, US
    "398705" # CENSYS-ARIN-02, US
    "398722" # CENSYS-ARIN-03, US
    "400161" # HAWAIIRESEARCH, US
  ];
  getBannedNetsScript =
    let
      pythonPkg = pkgs.python3.withPackages (ps: with ps; [ pyasn netaddr ]);
    in
    pkgs.writeScript "get-banned-nets.py" ''
      #!${pythonPkg}/bin/python
      import sys
      import pyasn
      from netaddr import IPNetwork, cidr_merge

      asns = ${concatStringsSep "," bannedASNs}
      print(f'Listing and merging nets for {len(asns)} ASNs', file=sys.stderr)

      asndb = pyasn.pyasn('${../constants/ipasn.dat.gz}')
      nets = set()
      for asn in asns:
        nets.update(asndb.get_as_prefixes(asn))
      print(f'Got {len(nets)} nets', file=sys.stderr)

      merged = cidr_merge([IPNetwork(ip) for ip in nets])
      print(f'Merged into {len(merged)} nets', file=sys.stderr)
      print('\n'.join(str(net) for net in merged))
    '';
in
{
  options.custom.ipset-block = {
    enable = mkEnableOption "Enable blocking potentially malicious IPs with ipset";
    exceptPorts = mkOption {
      description = "TCP ports to never block";
      type = types.listOf types.port;
      default = [ ];
    };
    # TODO: UDP
  };

  config = mkIf cfg.enable {
    networking.firewall =
      let
        ignorePorts = concatMapStringsSep "," (p: toString p) cfg.exceptPorts;
        iptablesArgs = "-p tcp -m state --state NEW ${ optionalString (ignorePorts != "") "-m multiport ! --dports ${ignorePorts}" } -m set --match-set ${ipsetName} src -j DROP";
      in
      {
        enable = true;
        extraPackages = [ pkgs.ipset ];

        extraCommands = ''
          ipset destroy ${ipsetName} || true
          ipset create ${ipsetName} hash:net
          iptables -I INPUT ${iptablesArgs}
          ${getBannedNetsScript} | while read net; do ipset add ${ipsetName} $net; done
        '';

        extraStopCommands = ''
          iptables -D INPUT ${iptablesArgs} || true
          iptables -F
          ipset destroy ${ipsetName} || true
        '';
      };
  };
}
