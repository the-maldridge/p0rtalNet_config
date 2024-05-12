job "zwave-js" {
  type = "service"

  datacenters = ["CONTROL"]
  region = "debon"
  namespace = "default"

  group "zwave" {
    count = 1

    network {
      mode = "cni/svcs"
      hostname = "zwave"
      port "http" { to = 8091 }
      port "api" { to = 3000 }
    }

    service {
      provider = "nomad"
      name = "zwave-http"
      port = "http"
      address_mode = "alloc"
      tags = ["nomad-ddns"]
    }

    service {
      provider = "nomad"
      name = "zwave-api"
      port = "api"
      address_mode = "alloc"
    }

    volume "zwave_data" {
      type = "host"
      source = "zwave_data"
      read_only = false
    }

    task "app" {
      driver = "docker"

      config {
        image = "docker.io/zwavejs/zwave-js-ui:9.10.2"
        devices = [{
          host_path = "/dev/serial/by-id/usb-Zooz_800_Z-Wave_Stick_533D004242-if00"
          container_path = "/dev/zwave"
        }]
      }

      volume_mount {
        volume = "zwave_data"
        destination = "/usr/src/app/store"
      }
    }
  }
}
