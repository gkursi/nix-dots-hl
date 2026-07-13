{
  getVolumePrefix =
    machine: service:
      builtins.elemAt
        machine.drives
        machine.services.${service}.drive;
}
