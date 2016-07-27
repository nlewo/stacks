# Bagpipe Terraform stack

Two Mitaka devstacks with bagpipe are deployed via a cloudinit file.

1. Source your openstack credentials;

2. `terraform apply -var ssh_key_file=~/.ssh/ssh-key-prefix`
   where your public ssh key must be ssh-key-prefix.pub, and your
   private ssh key must be ssh-key-prefix.private;

3. Ssh and `tmux a` on deployed VMs. You should then be able to ping qprobe-* netns from both VMs: `sudo ip netns exec qprobe-portid ping [12]0.0.0.3`

For more information:
- https://github.com/matrohon/devstack-conf/tree/master/test_bgpvpn_bagpipe
- https://github.com/openstack/networking-bgpvpn
