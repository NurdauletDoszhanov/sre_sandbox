variable "vms" {
  type = map(object({
    ip     = string
    core   = number
    memory = number
    os_type = string # 'ubuntu' or 'rocky' - just for reference if needed, but we rely on single template in this simple example or could make it map based
  }))
  default = {
    "mgmt-01"      = { ip = "192.168.1.10", core = 2, memory = 2048, os_type = "ubuntu" }
    "storage-01"   = { ip = "192.168.1.20", core = 2, memory = 2048, os_type = "rocky" }
    "hpc-master"   = { ip = "192.168.1.30", core = 2, memory = 4096, os_type = "rocky" }
    "hpc-worker-01"= { ip = "192.168.1.31", core = 4, memory = 8192, os_type = "rocky" }
    "k8s-master"   = { ip = "192.168.1.40", core = 2, memory = 4096, os_type = "ubuntu" }
    "k8s-gpu-01"   = { ip = "192.168.1.41", core = 4, memory = 8192, os_type = "ubuntu" }
  }
}

resource "proxmox_vm_qemu" "node" {
  for_each = var.vms

  name        = each.key
  target_node = var.proxmox_node
  clone       = var.template_name
  
  agent       = 1
  os_type     = "cloud-init"
  cores       = each.value.core
  sockets     = 1
  cpu         = "host"
  memory      = each.value.memory
  scsihw      = "virtio-scsi-pci"
  bootdisk    = "scsi0"

  disk {
    slot = 0
    size = "20G"
    type = "scsi"
    storage = "local-lvm" # Adjust storage pool as needed
  }

  network {
    model  = "virtio"
    bridge = "vmbr0"
  }
  
  # Cloud Init Settings
  ipconfig0 = "ip=${each.value.ip}/24,gw=${var.gateway}"
  sshkeys   = var.ssh_public_key
  
  lifecycle {
    ignore_changes = [
      network,
    ]
  }
}
