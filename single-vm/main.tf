resource "proxmox_vm_qemu" "vm" {
  vmid = 100
  name = var.vm_name

  target_node = var.proxmox_target_node
  clone       = var.proxmox_vm_template
  full_clone  = true

  os_type = "cloud-init"

  ciuser     = var.vm_user
  cipassword = var.vm_pass

  ipconfig0     = "ip=dhcp"
  agent_timeout = 120

  cores  = 1
  memory = 1024

  agent = 1

  bootdisk = "scsi0"
  scsihw   = "virtio-scsi-pci"

  serial {
    id   = 0
    type = "socket"
  }

  vga {
    type = "serial0"
  }

  disks {
    scsi {
      scsi0 {
        disk {
          size    = 10
          storage = "vms"
        }
      }
    }
    ide {
      ide1 {
        cloudinit {
          storage = "vms"
        }
      }
    }
  }

  network {
    id       = 0
    model    = "virtio"
    bridge   = "vmbr1"
    firewall = false
    tag      = 13
  }

  lifecycle {
    ignore_changes = [
      network
    ]
  }
}

output "vm_info" {
  value = "Hostname : ${proxmox_vm_qemu.vm.name}, IP Address : ${proxmox_vm_qemu.vm.default_ipv4_address}"
}
