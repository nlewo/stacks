# Bagpipe Terraform stack

Two Mitaka devstacks with bagpipe are deployed via to a cloudinit
file.

1. Source your openstack credentials;

2. `terraform apply -var ssh_key_file=~/.ssh/ssh-key-prefix`
   where your public ssh key must be ssh-key-prefix.pub, and your
   private ssh key must be ssh-key-prefix.private;

3. Ssh and `tmux a` on deployed VMs.
