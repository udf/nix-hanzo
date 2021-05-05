let
  private = import ./private.nix;
in
{
  serverIP = private.vpnServerIP;
  serverPort = 51820;
  gatewayIP = "10.100.0.1";
  torrentContainerIP = "10.100.0.2";
  torrentListenPort = 10810;
}