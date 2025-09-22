{ ... }:
{
  boot.kernel.sysctl = {
    # needed for monitoring IO% in iotop/htop
    "kernel.task_delayacct" = 1;
  };
}