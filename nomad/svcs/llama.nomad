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
        image = "llama-cpp/rocm:v0.4.1"
        # args  = [
        #   "-hf", "Doctor-Shotgun/MS3.2-24B-Magnum-Diamond-GGUF",
        #   "--ctx-size", "16384",
        #   "-fa", "1",
        # ]
        # args = [
        #   "--hf-repo", "anthracite-org/magnum-v4-123b-gguf",
        #   "--hf-file", "anthracite-core_magnum-v4-123b-Q3_K_L-00001-of-00003.gguf",
        #   "--flash-attn", "1",
        #   "--ctx-size", "16384",
        #   "--batch-size", "512",
        #   "--ubatch-size", "512",
        #   "--threads", "8",
        #   "--cache-type-k", "q8_0",
        #   "--cache-type-v", "q8_0",
        # ]
        args = [
          "--hf-repo", "unsloth/Qwen3.8-27B-GGUF",
          "--hf-file", "Qwen3.8-27B-UD-Q5_K_M.gguf",
          "--flash-attn", "1",
          "--ctx-size", "131072",
          "--parallel", "1",
          "--cache-type-k", "q4_0",
          "--cache-type-v", "q4_0",
          "--batch-size", "2048",
          "--ubatch-size", "512",
          "--temp", "1.0",
          "--top-p", "0.95",
          "--top-k", "20",
          "--min-p", "0.00",
        ]

        devices = [{
          host_path      = "/dev/dri"
          container_path = "/dev/dri"
          }, {
          host_path      = "/dev/kfd"
          container_path = "/dev/kfd"
        }]
      }

      resources {
        memory = 90000
      }

      env {
        GGML_CUDA_ENABLE_UNIFIED_MEMORY = 1
      }

      volume_mount {
        volume      = "llama_cache"
        destination = "/root/.cache"
      }
    }
  }
}
