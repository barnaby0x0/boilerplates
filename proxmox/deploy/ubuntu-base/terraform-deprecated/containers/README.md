if container to reach wireguard

1. Allow forwarding 

```bash
sysctl -w net.ipv4.ip_forward=1
```

2. restore the iptables.rules file by doing this command

```bash
iptables-restore < iptables.rules
```

3. Install wireguard-tools and put in /etc/wireguard/wg0.conf 
immich.conf from the vpn project (ansible)
