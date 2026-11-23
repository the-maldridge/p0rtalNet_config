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
        image = "llama-cpp/vulkan:v1.0.0"
        args = ["--models-preset", "/local/models.ini"]

        devices = [{
          host_path      = "/dev/dri"
          container_path = "/dev/dri"
        }]
      }

      resources {
        memory = 110000
      }

      env {
        GGML_VULKAN = "1"
        GGML_VULKAN_DEVICE = "0"
      }

      volume_mount {
        volume      = "llama_cache"
        destination = "/root/.cache"
      }

      template {
        data = <<EOT
[*]
models-max = 1

[magnum123b]
hf-repo = anthracite-org/magnum-v4-123b-gguf
hf-file = anthracite-core_magnum-v4-123b-Q3_K_L-00001-of-00003.gguf
flash-attn = 1
ctx-size = 16384
batch-size = 512
ubatch-size = 512
threads = 8
cache-type-k = q8_0
cache-type-v = q8_0

[qwen38_q4_k_m]
hf-repo = unsloth/Qwen3.8-27B-GGUF
hf-file = Qwen3.8-27B-UD-Q4_K_M.gguf
no-mmproj = true
device = vulkan0
n-gpu-layers = 99
flash-attn = true
ctx-size = 131072
parallel = 1
cache-type-k = f16
cache-type-v = f16
batch-size = 2048
ubatch-size = 256
temp = 0.2
top-p = 0.95
min-p = 0.05
jinja = true

[qwen38_q5_k_m]
hf-repo = unsloth/Qwen3.8-27B-GGUF
hf-file = Qwen3.8-27B-UD-Q5_K_M.gguf
no-mmproj = true
device = vulkan0
n-gpu-layers = 99
flash-attn = true
ctx-size = 131072
parallel = 1
cache-type-k = f16
cache-type-v = f16
batch-size = 2048
ubatch-size = 256
temp = 0.2
top-p = 0.95
min-p = 0.05
jinja = true

[qwen38_q5_k_xl]
hf-repo = unsloth/Qwen3.8-27B-GGUF
hf-file = Qwen3.8-27B-UD-Q5_K_XL.gguf
no-mmproj = true
device = vulkan0
n-gpu-layers = 99
flash-attn = true
ctx-size = 131072
parallel = 1
cache-type-k = f16
cache-type-v = f16
batch-size = 2048
ubatch-size = 256
temp = 0.2
top-p = 0.95
min-p = 0.05
jinja = true

[qwen38_flash_next_mtp]
hf-repo = unsloth/Qwen3.8-Flash-Next-GGUF
hf-file = UD-IQ4_XS/Qwen3.8-Flash-Next-UD-IQ4_XS-00001-of-00004.gguf
no-mmproj = true
device = vulkan0
n-gpu-layers = 99
flash-attn = true
ctx-size = 262144
parallel = 1
cache-type-k = q8_0
cache-type-v = q8_0
batch-size = 2048
ubatch-size = 512
temp = 1.0
top-p = 0.95
top-k = 20
min-p = 0.0
jinja = true
spec-draft-model = /root/.cache/models/mtp-Qwen3.8-Flash-Next-Q8_0.gguf
spec-type = draft-mtp
spec-draft-n-max = 2
EOT
        destination = "local/models.ini"
      }
    }
  }
}
