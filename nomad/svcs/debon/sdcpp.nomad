job "sdcpp" {
  type        = "service"
  datacenters = ["WORKER"]
  region      = "debon"
  namespace   = "default"

  group "sdcpp" {
    count = 1

    network {
      mode = "cni/svcs"
      port "http" { to = 7860 }
    }

    service {
      provider     = "nomad"
      name         = "sdcpp"
      port         = "http"
      address_mode = "alloc"
      tags         = ["traefik.enable=true"]
    }

    dynamic "volume" {
      for_each = ["models", "outputs", "config"]
      labels   = ["sd_${volume.value}"]
      content {
        type      = "host"
        source    = "sd_${volume.value}"
        read_only = false
      }
    }

    task "sdcpp" {
      driver = "docker"

      config {
        image = "sdwebui:3441970"
        devices = [{
          host_path      = "/dev/dri"
          container_path = "/dev/dri"
        }]
      }

      resources {
        memory = 4000
      }

      dynamic "volume_mount" {
        for_each = ["models", "outputs", "config"]

        content {
          volume      = "sd_${volume_mount.value}"
          destination = "/sd/${volume_mount.value}"
        }
      }
    }
  }
}
