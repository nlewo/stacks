output "master" {
    value = "ssh -i ${var.ssh_key_file}.private cloud@${openstack_networking_floatingip_v2.master.address}"
}
output "slave" {
    value = "ssh -i ${var.ssh_key_file}.private cloud@${openstack_networking_floatingip_v2.slave.address}"
}
