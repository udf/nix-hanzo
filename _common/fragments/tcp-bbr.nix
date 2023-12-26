{ ... }:
{
  boot.kernel.sysctl = {
    "net.core.wmem_max" = 12582912;
    "net.core.rmem_max" = 12582912;
    "net.ipv4.tcp_rmem" = "4096	524000	16777216";
    "net.ipv4.tcp_wmem" = "4096	524000	16777216";
    "net.core.default_qdisc" = "fq";
    "net.ipv4.tcp_congestion_control" = "bbr";
  };
}