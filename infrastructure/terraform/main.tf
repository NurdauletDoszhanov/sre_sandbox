variable "vms" {
  type = map(object({
    ip      = string
    cpus    = number
    memory  = string
    disk    = string
  }))
  default = {
    "mgmt-01"       = { ip = "192.168.1.10", cpus = 1, memory = "1G", disk = "10G" }
    "storage-01"    = { ip = "192.168.1.20", cpus = 1, memory = "1G", disk = "20G" }
    "hpc-master"    = { ip = "192.168.1.30", cpus = 2, memory = "2G", disk = "10G" }
    "hpc-worker-01" = { ip = "192.168.1.31", cpus = 2, memory = "3G", disk = "10G" }
    "k8s-master"    = { ip = "192.168.1.40", cpus = 2, memory = "2G", disk = "15G" }
    "k8s-gpu-01"    = { ip = "192.168.1.41", cpus = 2, memory = "3G", disk = "15G" }
  }
}

variable "ubuntu_image" {
  type        = string
  default     = "22.04"
  description = "Ubuntu image version for Multipass (e.g., 22.04, 24.04, jammy, noble)"
}

resource "null_resource" "multipass_vm" {
  for_each = var.vms

  triggers = {
    vm_name = each.key
    cpus    = each.value.cpus
    memory  = each.value.memory
    disk    = each.value.disk
    image   = var.ubuntu_image
  }

  provisioner "local-exec" {
    command     = "multipass launch ${var.ubuntu_image} --name ${each.key} --cpus ${each.value.cpus} --memory ${each.value.memory} --disk ${each.value.disk}"
    interpreter = ["powershell", "-Command"]
  }

  provisioner "local-exec" {
    when        = destroy
    command     = "multipass delete ${self.triggers.vm_name} --purge"
    interpreter = ["powershell", "-Command"]
    on_failure  = continue
  }
}

output "vm_info" {
  value = {
    for name, config in var.vms : name => {
      cpus   = config.cpus
      memory = config.memory
      disk   = config.disk
      image  = var.ubuntu_image
    }
  }
  description = "Configuration of created Multipass VMs"
}

output "get_ips_command" {
  value       = "multipass list"
  description = "Run this command to see VM IP addresses"
}
