job "dnscopy" {
  type = "service"

  datacenters = ["CONTROL"]
  region = "debon"
  namespace = "default"

  group "dnscopy" {
    count = 1

    volume "dnsmasq_hosts" {
      type = "host"
      source = "dnsmasq_hosts"
      read_only = false
    }

    task "app" {
      driver = "docker"

      config {
        image = "docker.io/library/alpine:latest"
        entrypoint = ["/local/entrypoint"]
        init = true
      }

      volume_mount {
        volume = "dnsmasq_hosts"
        destination = "/host"
      }

      template {
        data = <<EOF
#!/bin/sh
cp /local/hosts /host
exec sleep infinity
EOF
        destination = "local/entrypoint"
        perms = "755"
      }

      template {
        data = <<EOF
{{ range nomadServices -}}
{{ range nomadService .Name -}}
{{.Address}} {{.Name}}.dal.michaelwashere.net
{{ end -}}
{{ end -}}
EOF
        destination = "local/hosts"
        change_mode = "script"
        change_script {
          command = "/bin/cp"
          args = [
            "/local/hosts",
            "/host/",
          ]
        }
      }
    }
  }
}
