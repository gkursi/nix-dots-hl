{
  sops.age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
  virtualisation.docker.enable = false;
  virtualisation.podman.enable = true;
  virtualisation.arion.backend = "podman-socket";

  virtualisation.podman.dockerSocket.enable = true;
  virtualisation.podman.defaultNetwork.settings.dns_enabled = true;

  users.users.root.extraGroups = [ "podman" ];
}
