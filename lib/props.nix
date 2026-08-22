{
  getPropertyOrDefault =
    machine: service: prop: default:
      machine.services.${service}.${prop} or default;

  getProperty =
    machine: service: prop:
      machine.services.${service}.${prop};
}
