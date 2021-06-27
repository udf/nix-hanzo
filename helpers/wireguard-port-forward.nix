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
    ${iptables} -t nat -A ${prefixChain "PREROUTING"} -i ${externalInterface} -p ${proto} --dport ${port} -j DNAT --to-destination ${ip}
  '';
in
(removeAttrs cfg ["forwardedTCPPorts" "forwardedUDPPorts"]) // {
  postSetup = (cfg.postSetup or "") + ''
    ${createChain {table="nat"; chain="PREROUTING";}}

    ${builtins.concatStringsSep "\n" (lib.mapAttrsToList (port: ip: (getForwardRules {proto="tcp"; port=port; ip=ip;})) forwardedTCPPorts)}
    ${builtins.concatStringsSep "\n" (lib.mapAttrsToList (port: ip: (getForwardRules {proto="udp"; port=port; ip=ip;})) forwardedUDPPorts)}
  '';
  postShutdown = (cfg.postShutdown or "") + ''
    ${deleteChain {table="nat"; chain="PREROUTING";}}
  '';
}