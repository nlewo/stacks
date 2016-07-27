#cloud-config

packages:
  - git
  - emacs23-nox
  - dkms
  - make
  - libc6-dev
  
write_files:
  - path: /opt/run.sh
    content: |
      cd ~/
      git clone https://github.com/matrohon/devstack-conf.git
      sudo dpkg -i ~/devstack-conf/test_bgpvpn_bagpipe/deb/openvswitch-*

      git clone https://git.openstack.org/openstack-dev/devstack

      cd devstack/
      git checkout stable/mitaka

      cp ~/devstack-conf/test_bgpvpn_bagpipe/local.conf.bgpvpn.bagpipe ./local.conf
      cp ~/devstack-conf/test_bgpvpn_bagpipe/stack-bgpvpn-bagpipe.sh ./
      cp ~/devstack-conf/test_bgpvpn_bagpipe/stack.yaml ./
        
      ${env} ./stack-bgpvpn-bagpipe.sh

runcmd:
  - su cloud -c "tmux new-session -d"
  - su cloud -c "tmux send-keys -t 0 'bash -x -e /opt/run.sh' enter"
