package kubernetes.admission

# Deny privileged containers

deny[msg] {
  input.request.kind.kind == "Pod"
  some c in input.request.object.spec.containers
  c.securityContext.privileged == true
  msg := sprintf("Privileged container not allowed: %s", [c.name])
}

# Require non-root containers

deny[msg] {
  input.request.kind.kind == "Pod"
  some c in input.request.object.spec.containers
  not c.securityContext.runAsNonRoot
  msg := sprintf("runAsNonRoot must be true: %s", [c.name])
}

# Disallow :latest image tags

deny[msg] {
  input.request.kind.kind == "Pod"
  some c in input.request.object.spec.containers
  endswith(c.image, ":latest")
  msg := sprintf("Image tag :latest is not allowed: %s", [c.image])
}

# Require resource requests/limits

deny[msg] {
  input.request.kind.kind == "Pod"
  some c in input.request.object.spec.containers
  not c.resources.requests.cpu
  msg := sprintf("CPU requests required: %s", [c.name])
}

deny[msg] {
  input.request.kind.kind == "Pod"
  some c in input.request.object.spec.containers
  not c.resources.limits.memory
  msg := sprintf("Memory limits required: %s", [c.name])
}

# Block hostPath volumes

deny[msg] {
  input.request.kind.kind == "Pod"
  some v in input.request.object.spec.volumes
  v.hostPath
  msg := "hostPath volumes are not allowed"
}
