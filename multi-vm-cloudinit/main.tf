resource "local_file" "cloud_init_user_data_file" {
  for_each = toset(var.vm_names)
  content = templatefile("${path.module}/cloudinit/cloudinit-template.tftpl", {
    username = var.vm_user
    password = var.vm_pass
    hostname = each.value
  })
  filename = "${path.module}/files/user_data_vm_${each.value}.cfg"
}

resource "null_resource" "cloud_init_config_files" {
  for_each = toset(var.vm_names)
  connection {
    type     = "ssh"
    user     = var.proxmox_ssh_user
    password = var.proxmox_ssh_pass
    host     = var.proxmox_ssh_host
  }

  provisioner "file" {
    source      = local_file.cloud_init_user_data_file[each.value].filename
    destination = "/var/lib/vz/snippets/user_data_vm_${each.value}.yaml"
  }
}

resource "proxmox_vm_qemu" "vm" {

  depends_on = [
    null_resource.cloud_init_config_files
  ]

  count = length(var.vm_names)
  name  = var.vm_names[count.index]

  target_node = var.proxmox_target_node
  clone       = var.proxmox_vm_template
  full_clone  = true

  os_type = "cloud-init"

  cicustom      = "user=local:snippets/user_data_vm_${var.vm_names[count.index]}.yaml"
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
  value = [
    for vm in proxmox_vm_qemu.vm : {
      hostname = vm.name
      ip-addr  = vm.default_ipv4_address
    }
  ]
}
