  - Avant de démarrer le clone il est important de supprimer le stockage contenant le cloudinit.

régles iptables et de routage

sudo ip address add 10.0.0.1/24 dev ens19
sudo ip link set ens19 up

sudo sysctl -w net.ipv4.ip_forward=1
sudo iptables -I FORWARD 1 -i ens19 -o ens18 -j ACCEPT
sudo iptables -I FORWARD 1 -i ens18 -o ens19 -j ACCEPT
sudo iptables -t nat -A POSTROUTING -o ens18 -j MASQUERADE
