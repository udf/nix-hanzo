{ config, lib, pkgs, options, ... }:
with lib;
let
  cfg = config.custom.ipset-block;
  ipsetName = "badnets";
  bannedASNs = {
    "701" = "UUNET, US";
    "2518" = "BIGLOBE BIGLOBE Inc., JP";
    "2637" = "GEORGIA-TECH, US";
    "2856" = "BT-UK-AS BTnet UK Regional network, GB";
    "3462" = "HINET Data Communication Business Group, TW";
    "3737" = "AS-PTD, US";
    "4134" = "CHINANET-BACKBONE No.31,Jin-rong Street, CN";
    "4766" = "KIXS-AS-KR Korea Telecom, KR";
    "4837" = "CHINA169-BACKBONE CHINA UNICOM China169 Backbone, CN";
    "6939" = "HURRICANE, US";
    "7303" = "Telecom Argentina S.A., AR";
    "8075" = "MICROSOFT-CORP-MSN-AS-BLOCK, US";
    "9009" = "M247, RO";
    "9232" = "NTTE-AS Ntte Global Network Brand Name, HK";
    "9465" = "AGOTOZPTELTD-AS-AP AGOTOZ PTE. LTD., SG";
    "9698" = "YOUNGDOONG-AS-KR LG HelloVision Corp., KR";
    "9808" = "CHINAMOBILE-CN China Mobile Communications Group Co., Ltd., CN";
    "9829" = "BSNL-NIB National Internet Backbone, IN";
    "10796" = "TWC-10796-MIDWEST, US";
    "12876" = "Online SAS, FR";
    "14061" = "DIGITALOCEAN-ASN, US";
    "16276" = "OVH, FR";
    "16509" = "AMAZON-02, US";
    "19318" = "IS-AS-1, US";
    "20473" = "AS-CHOOPA, US";
    "21859" = "ZEN-ECN, US";
    "24186" = "RAILTEL-AS-IN RailTel Corporation of India Ltd, IN";
    "25820" = "IT7NET, CA";
    "32613" = "IWEB-AS, CA";
    "34797" = "SYSTEM-NET, GE";
    "37963" = "ALIBABA-CN-NET Hangzhou Alibaba Advertising Co.,Ltd., CN";
    "38186" = "FTG-AS-AP Forewin Telecom Group Limited, ISP at, HK";
    "39421" = "SAPINET-AS, FR";
    "45102"= "ALIBABA-CN-NET Alibaba US Technology Co., Ltd., CN";
    "45204" = "GEMNET-MN GEMNET LLC, MN";
    "47890" = "UNMANAGED-DEDICATED-SERVERS, GB";
    "48090" = "PPTECHNOLOGY, GB";
    "48266" = "AS-CATIXS, GB";
    "48693" = "NTSERVICE-AS, UA";
    "48721" = "FLYSERVERS-ENDCLIENTS, PA";
    "49581" = "FERDINANDZINK, DE";
    "50304" = "BLIX, NO";
    "50867" = "HOSTKEY-RU-AS, NL";
    "51167" = "CONTABO, DE";
    "51396" = "PFCLOUD, DE";
    "51852" = "PLI-AS, PA";
    "55933" = "CLOUDIE-AS-AP Cloudie Limited, HK";
    "56380" = "AS-ITFRUIT, MD";
    "57043" = "HOSTKEY-AS, NL";
    "57523" = "CHANGWAY-AS, HK";
    "57678" = "CATTECHNOLOGIES-AS, HK";
    "58061" = "SCALAXY-AS, LV";
    "58461" = "CT-HANGZHOU-IDC No.288,Fu-chun Road, CN";
    "59502" = "SO-AS, RU";
    "60223" = "NETIFACE-AS Netiface Europe, GB";
    "60781" = "LEASEWEB-NL-AMS-01 Netherlands, NL";
    "61432" = "VAIZ-AS ITBks892, UA";
    "63199" = "CDSC-AS1, US";
    "63949" = "AKAMAI-LINODE-AP Akamai Connected Cloud, SG";
    "132203" = "TENCENT-NET-AP-CN Tencent Building, Kejizhongyi Avenue, CN";
    "135377" = "UCLOUD-HK-AS-AP UCLOUD INFORMATION TECHNOLOGY HK LIMITED, HK";
    "135636" = "RACKH-AS-AP Rackh Lintas Asia, pt, ID";
    "136180" = "IPIP-CN Beijing Tiantexin Tech. Co., Ltd., CN";
    "138915" = "KAOPU-HK Kaopu Cloud HK Limited, HK";
    "138968" = "RAINBOWIDC-AS-AP rainbow network limited, JP";
    "141995" = "CAPL-AS-AP Contabo Asia Private Limited, SG";
    "142002" = "SCLOUDPTELTD-AS Scloud Pte Ltd, SG";
    "148981" = "CHINANET-HUBEI-SHIYAN-IDC China Telecom, CN";
    "197183" = "OCCENTUS, ES";
    "200052" = "FERAL Feral Hosting, GB";
    "201814" = "MEVSPACE, PL";
    "202425" = "INT-NETWORK, SC";
    "204428" = "SS-NET, BG";
    "207812" = "DM_AUTO, BG";
    "209132" = "AS209132, SC";
    "209588" = "FLYSERVERS-ASN, PA";
    "209605" = "HOSTBALTIC, LT";
    "211298" = "INTERNET-MEASUREMENT, GB";
    "211619" = "MAXKO, HR";
    "211680" = "AS-BITSIGHT, PT";
    "211736" = "FDN3, UA";
    "213613" = "BOTSHIELD-LTD, GB";
    "214943" = "RAILNET, US";
    "215292" = "GRAVHOSTING, GB";
    "215540" = "GCS-AS, GB";
    "265157" = "MICROTELL SCM LTDA, BR";
    "327996" = "ACCELERIT, ZA";
    "328543" = "sun-asn, SC";
    "329197" = "TForge, ZA";
    "396982" = "GOOGLE-CLOUD-PLATFORM, US";
    "398324" = "CENSYS-ARIN-01, US";
    "398705" = "CENSYS-ARIN-02, US";
    "398722" = "CENSYS-ARIN-03, US";
    "400161" = "HAWAIIRESEARCH, US";
    "401120" = "CHEAPY-HOST, US";
  };
  getBannedNetsScript =
    let
      pythonPkg = pkgs.python3.withPackages (ps: with ps; [ pyasn netaddr ]);
    in
    pkgs.writeScript "get-banned-nets.py" ''
      #!${pythonPkg}/bin/python
      import sys
      import json
      import pyasn
      from netaddr import IPNetwork, cidr_merge

      bannedASNs = json.loads(''''
      ${builtins.toJSON bannedASNs}
      '''')

      print(f'Listing and merging nets for {len(bannedASNs)} ASNs', file=sys.stderr)

      asndb = pyasn.pyasn(
        '${../constants/ipasn.dat.gz}',
        as_names_file='${../constants/asnames.json}'
      )
      nets = set()
      for asn, name in bannedASNs.items():
        cur_name = asndb.get_as_name(asn)
        if not cur_name != name:
          print(f'<4>AS{asn} has an unexpected name! {name!r} != {cur_name!r}', file=sys.stderr)
        prefixes = asndb.get_as_prefixes(asn)
        if not prefixes:
          print(f'<4>AS{asn} has no prefixes!', file=sys.stderr)
          continue
        nets.update(prefixes)
      print(f'Got {len(nets)} nets', file=sys.stderr)

      merged = cidr_merge([IPNetwork(ip) for ip in nets])
      num_ips = sum((net.hostmask.value or 0) + 1 for net in merged)
      print(f'Merged into {len(merged)} nets ({num_ips} IPs) ({num_ips / 2**32 * 100:.2f}%)', file=sys.stderr)
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
