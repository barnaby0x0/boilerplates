 ## Install gui cmds

 ```bash
#!/usr/bin/env bash
set -euo pipefail

# Vérification basique
if ! command -v apt >/dev/null 2>&1; then
  echo "Ce script doit être lancé sur une distribution basée sur APT (Ubuntu, Debian...)."
  exit 1
fi

# Màj des index de paquets
sudo apt update

# Installation de XFCE4 (environnement de bureau de base)
sudo DEBIAN_FRONTEND=noninteractive \
  apt install -y xfce4

# Installation de gdm3 (display manager GNOME)
sudo DEBIAN_FRONTEND=noninteractive \
  apt install -y gdm3

# Forcer gdm3 comme display manager par défaut (sans invite interactive)
echo "gdm3 shared/default-x-display-manager select gdm3" | sudo debconf-set-selections
sudo dpkg-reconfigure -f noninteractive gdm3

echo
echo "Installation terminée."
echo "Redémarre la machine puis sélectionne la session XFCE à l'écran de connexion gdm3."
 ```

## Load secrets from Vault

```bash 
while IFS=':' read -r e k v; do eval "export $e=\"\$(vault kv get -field=$k $v)\""; done < .env
```
.env file has the format as bellow

```bash
env_var_name:secret_key:secret_path
exemple: TF_VAR_test:test:secret/terraform/test
```