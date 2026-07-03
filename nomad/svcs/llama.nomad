job "llama" {
  type        = "service"
  datacenters = ["WORKER"]
  region      = "debon"
  namespace   = "default"

  group "llama" {
    count = 1

    network {
      mode = "cni/svcs"
      port "http" { to = 8080 }
    }

    service {
      provider     = "nomad"
      name         = "llama"
      port         = "http"
      address_mode = "alloc"
      tags         = ["traefik.enable=true"]
    }

    volume "llama_cache" {
      type      = "host"
      source    = "llama_cache"
      read_only = false
    }

    task "llama" {
      driver = "docker"

      config {
        image = "llama-cpp/vulkan:3ac3c20c9"
        args  = ["-hf", "Doctor-Shotgun/MS3.2-24B-Magnum-Diamond-GGUF", "--fit", "off"]
        # args = [
        #   "-hf", "unsloth/Qwen3.6-27B-MTP-GGUF:UD-Q4_K_XL",
        #   "--temp", "1.0",
        #   "--top-p", "0.95",
        #   "--top-k", "20",
        #   "--min-p", "0.00",
        #   "--spec-type", "draft-mtp", "--spec-draft-n-max", "2",
        # ]

        devices = [{
          host_path      = "/dev/dri"
          container_path = "/dev/dri"
        }]
      }

      resources {
        memory = 20000
      }

      volume_mount {
        volume      = "llama_cache"
        destination = "/root/.cache/llama.cpp"
      }
    }
  }
}
