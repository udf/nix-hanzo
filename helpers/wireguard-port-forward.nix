{
  lib,
  pkgs,
  interface,
  externalInterface,
  gatewayIP,
  gatewaySubnet
}: {forwardedTCPPorts, forwardedUDPPorts, ...} @ cfg:
let
  iptables = "${pkgs.iptables}/bin/iptables";
  prefixChain = chain: "${chain}_${lib.toUpper interface}";
  getTableArg = table: lib.optionalString (table != "") "-t ${table}";

  createChain = {chain, table ? ""}: ''
    ${iptables} ${getTableArg table} -N ${prefixChain chain}
    ${iptables} ${getTableArg table} -A ${chain} -j ${prefixChain chain}
  '';
  deleteChain = {chain, table ? ""}: ''
    ${iptables} ${getTableArg table} -D ${chain} -j ${prefixChain chain}
    ${iptables} ${getTableArg table} -F ${prefixChain chain}
    ${iptables} ${getTableArg table} -X ${prefixChain chain}
  '';
  getForwardRules = {proto ? "tcp", port, ip}: ''
    ${iptables} -A ${prefixChain "FORWARD"} -i ${externalInterface} -o ${interface} -p ${proto} ${lib.optionalString (proto == "tcp") "--syn"} --dport ${port} -m conntrack --ctstate NEW -j ACCEPT
    ${iptables} -t nat -A ${prefixChain "PREROUTING"} -i ${externalInterface} -p ${proto} --dport ${port} -j DNAT --to-destination ${ip}
    ${iptables} -t nat -A ${prefixChain "POSTROUTING"} -o ${interface} -p ${proto} --dport ${port} -d ${ip} -j SNAT --to-source ${gatewayIP}
  '';
in
(removeAttrs cfg ["forwardedTCPPorts" "forwardedUDPPorts"]) // {
  postSetup = (cfg.postSetup or "") + ''
    ${createChain {table="nat"; chain="POSTROUTING";}}
    ${createChain {table="nat"; chain="PREROUTING";}}
    ${createChain {chain="FORWARD";}}

    ${iptables} -t nat -A ${prefixChain "POSTROUTING"} -s ${gatewaySubnet} -o ${externalInterface} -j MASQUERADE

    ${iptables} -A ${prefixChain "FORWARD"} -i ${externalInterface} -o ${interface} -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
    ${iptables} -A ${prefixChain "FORWARD"} -i ${interface} -o ${externalInterface} -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT

    ${builtins.concatStringsSep "\n" (lib.mapAttrsToList (port: ip: (getForwardRules {proto="tcp"; port=port; ip=ip;})) forwardedTCPPorts)}
    ${builtins.concatStringsSep "\n" (lib.mapAttrsToList (port: ip: (getForwardRules {proto="udp"; port=port; ip=ip;})) forwardedUDPPorts)}
  '';
  postShutdown = (cfg.postShutdown or "") + ''
    ${deleteChain {table="nat"; chain="POSTROUTING";}}
    ${deleteChain {table="nat"; chain="PREROUTING";}}
    ${deleteChain {chain="FORWARD";}}
  '';
}