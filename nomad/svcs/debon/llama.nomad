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
        image = "llama-cpp:vulkan"
        args  = ["-hf", "cognitivecomputations/Dolphin3.0-Llama3.1-8B-GGUF"]
        devices = [{
          host_path      = "/dev/dri"
          container_path = "/dev/dri"
        }]
      }

      resources {
        memory = 4000
      }

      volume_mount {
        volume      = "llama_cache"
        destination = "/root/.cache/llama.cpp"
      }
    }
  }
}
