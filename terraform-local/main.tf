
# HELIOS dedicated local Docker network

resource "docker_network" "helios" {
  name   = "helios-network"
  driver = "bridge"

  labels {
    label = "project"
    value = "HELIOS"
  }

  labels {
    label = "managed_by"
    value = "terraform"
  }
}
