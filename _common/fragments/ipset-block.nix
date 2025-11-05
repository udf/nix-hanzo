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
    "3269" = "ASN-IBSNAZ, IT";
    "3462" = "HINET Data Communication Business Group, TW";
    "3737" = "AS-PTD, US";
    "4134" = "CHINANET-BACKBONE No.31,Jin-rong Street, CN";
    "4766" = "KIXS-AS-KR Korea Telecom, KR";
    "4773" = "MOBILEONELTD-AS-AP MobileOne Ltd. MobileInternet Service Provider Singapore, SG";
    "4837" = "CHINA169-BACKBONE CHINA UNICOM China169 Backbone, CN";
    "5769" = "VIDEOTRON, CA";
    "6939" = "HURRICANE, US";
    "7018" = "ATT-INTERNET4, US";
    "7303" = "Telecom Argentina S.A., AR";
    "7562" = "HCNSEOCHO-AS-KR HCN Dongjak, KR";
    "7684" = "SAKURA-A SAKURA Internet Inc., JP";
    "7713" = "TELKOMNET-AS-AP PT Telekomunikasi Indonesia, ID";
    "7922" = "COMCAST-7922, US";
    "8075" = "MICROSOFT-CORP-MSN-AS-BLOCK, US";
    "9009" = "M247, RO";
    "9105" = "TISCALI-UK TalkTalk Communications Limited, GB";
    "9232" = "NTTE-AS Ntte Global Network Brand Name, HK";
    "9465" = "AGOTOZPTELTD-AS-AP AGOTOZ PTE. LTD., SG";
    "9506" = "SINGTEL-FIBRE Singtel Fibre Broadband, SG";
    "9698" = "YOUNGDOONG-AS-KR LG HelloVision Corp., KR";
    "9762" = "HCN-AS HYUNDAI COMMUNICATIONS NETWORK, KR";
    "9808" = "CHINAMOBILE-CN China Mobile Communications Group Co., Ltd., CN";
    "9829" = "BSNL-NIB National Internet Backbone, IN";
    "10439" = "CARINET, US";
    "10617" = "SION S.A, AR";
    "10796" = "TWC-10796-MIDWEST, US";
    "11320" = "LIGHTEDGE-AS-02, US";
    "12389" = "ROSTELECOM-AS, RU";
    "12816" = "MWN-AS, DE";
    "12876" = "Online SAS, FR";
    "14061" = "DIGITALOCEAN-ASN, US";
    "16276" = "OVH, FR";
    "16509" = "AMAZON-02, US";
    "17676" = "GIGAINFRA SoftBank Corp., JP";
    "17858" = "POWERVIS-AS-KR LG POWERCOMM, KR";
    "18779" = "EGIHOSTING, US";
    "19318" = "IS-AS-1, US";
    "20473" = "AS-CHOOPA, US";
    "21859" = "ZEN-ECN, US";
    "22884" = "TOTAL PLAY TELECOMUNICACIONES SA DE CV, MX";
    "24186" = "RAILTEL-AS-IN RailTel Corporation of India Ltd, IN";
    "25820" = "IT7NET, CA";
    "32613" = "IWEB-AS, CA";
    "34797" = "SYSTEM-NET, GE";
    "36352" = "AS-COLOCROSSING, US";
    "37963" = "ALIBABA-CN-NET Hangzhou Alibaba Advertising Co.,Ltd., CN";
    "38186" = "FTG-AS-AP Forewin Telecom Group Limited, ISP at, HK";
    "39421" = "SAPINET-AS, FR";
    "41608" = "NEXTGENWEBS-NL, ES";
    "42337" = "RESPINA-AS, IR";
    "45090" = "TENCENT-NET-AP Shenzhen Tencent Computer Systems Company Limited, CN";
    "45102" = "ALIBABA-CN-NET Alibaba US Technology Co., Ltd., CN";
    "45204" = "GEMNET-MN GEMNET LLC, MN";
    "45235" = "GEONET GEOCITY NETWORK SOLUTIONS PVT LTD, IN";
    "45374" = "CCS-AS-KR CCS, KR";
    "46261" = "QUICKPACKET, US";
    "47154" = "HUSAM-NETWORK, PS";
    "47583" = "AS-HOSTINGER, CY";
    "47890" = "UNMANAGED-DEDICATED-SERVERS, GB";
    "48090" = "PPTECHNOLOGY, GB";
    "48266" = "AS-CATIXS, GB";
    "48693" = "NTSERVICE-AS, UA";
    "48721" = "FLYSERVERS-ENDCLIENTS, PA";
    "49434" = "FBWNETWORKS, FR";
    "49453" = "GLOBALLAYER, NL";
    "49544" = "I3DNET, NL";
    "49581" = "FERDINANDZINK, DE";
    "49870" = "AS49870-BV, NL";
    "50304" = "BLIX, NO";
    "50867" = "HOSTKEY-RU-AS, NL";
    "51167" = "CONTABO, DE";
    "51396" = "PFCLOUD, DE";
    "51852" = "PLI-AS, PA";
    "52053" = "REDHEBERG, FR";
    "55430" = "STARHUB-NGNBN Starhub Ltd, SG";
    "55933" = "CLOUDIE-AS-AP Cloudie Limited, HK";
    "55990" = "HWCSNET Huawei Cloud Service data center, CN";
    "56380" = "AS-ITFRUIT, MD";
    "57043" = "HOSTKEY-AS, NL";
    "57523" = "CHANGWAY-AS, HK";
    "57678" = "CATTECHNOLOGIES-AS, HK";
    "58061" = "SCALAXY-AS, LV";
    "58224" = "TCI, IR";
    "58461" = "CT-HANGZHOU-IDC No.288,Fu-chun Road, CN";
    "58466" = "CT-GUANGZHOU-IDC CHINANET Guangdong province network, CN";
    "59502" = "SO-AS, RU";
    "60223" = "NETIFACE-AS Netiface Europe, GB";
    "60781" = "LEASEWEB-NL-AMS-01 Netherlands, NL";
    "61432" = "VAIZ-AS ITBks892, UA";
    "63199" = "CDSC-AS1, US";
    "63949" = "AKAMAI-LINODE-AP Akamai Connected Cloud, SG";
    "64286" = "LOGICWEB, US";
    "132203" = "TENCENT-NET-AP-CN Tencent Building, Kejizhongyi Avenue, CN";
    "133275" = "GIGANTIC-AS Gigantic Infotel Pvt Ltd, IN";
    "135377" = "UCLOUD-HK-AS-AP UCLOUD INFORMATION TECHNOLOGY HK LIMITED, HK";
    "135636" = "RACKH-AS-AP Rackh Lintas Asia, pt, ID";
    "136180" = "IPIP-CN Beijing Tiantexin Tech. Co., Ltd., CN";
    "138915" = "KAOPU-HK Kaopu Cloud HK Limited, HK";
    "138968" = "RAINBOWIDC-AS-AP rainbow network limited, JP";
    "141892" = "IDNIC-SENGKED-AS-ID CV Andhika Pratama Sanggoro, ID";
    "141995" = "CAPL-AS-AP Contabo Asia Private Limited, SG";
    "142002" = "SCLOUDPTELTD-AS Scloud Pte Ltd, SG";
    "148981" = "CHINANET-HUBEI-SHIYAN-IDC China Telecom, CN";
    "197183" = "OCCENTUS, ES";
    "200052" = "FERAL Feral Hosting, GB";
    "201579" = "HOSTGNOME-AS, GB";
    "201814" = "MEVSPACE, PL";
    "202306" = "HOSTGLOBALPLUS-AS, GB";
    "202425" = "INT-NETWORK, SC";
    "204428" = "SS-NET, BG";
    "206264" = "AMARUTU-TECHNOLOGY, SC";
    "207812" = "DM_AUTO, BG";
    "208317" = "SF-DIGITALSERVICES, MD";
    "209132" = "AS209132, SC";
    "209588" = "FLYSERVERS-ASN, PA";
    "209605" = "HOSTBALTIC, LT";
    "209805" = "SBCLOUD, RU";
    "210369" = "MXCLOUD-AS, GB";
    "211298" = "INTERNET-MEASUREMENT, GB";
    "211590" = "BUCKLOG, FR";
    "211619" = "MAXKO, HR";
    "211680" = "AS-BITSIGHT, PT";
    "211736" = "FDN3, UA";
    "213412" = "ONYPHE, FR";
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
      print('\n'.join(f"add ${ipsetName} {net}" for net in merged))
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
    systemd.services."ipset-${ipsetName}-load" = {
      description = "Load banned networks into ipset ${ipsetName}";
      requiredBy = [ "firewall.service" ];
      partOf = [ "firewall.service" ];
      after = [ "firewall.service" ];
      path = [ pkgs.ipset ];
      serviceConfig = {
        Type = "oneshot";
      };

      script = ''
        ${getBannedNetsScript} | ipset restore
      '';
    };

    systemd.services.firewall.restartTriggers = [ getBannedNetsScript ];

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
          systemctl start --no-block ipset-${ipsetName}-load.service
        '';

        extraStopCommands = ''
          iptables -D INPUT ${iptablesArgs} || true
          ipset destroy ${ipsetName} || true
        '';
      };
  };
}
