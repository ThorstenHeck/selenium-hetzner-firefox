# Ubuntu

USER_ORIG=$USER
PW_OPNVPN=$(op get item "Ansible-User" --fields password)
config=OPNSense_VPN_Server_vanilla_root_client_local.ovpn
name=OPNSense_VPN_Server_vanilla_root_client_local
user=ansible


sudo echo "%$USER_ORIG ALL=NOPASSWD: /bin/systemctl restart NetworkManager" | sudo tee /etc/sudoers.d/$USER_ORIG
sudo echo "%$USER_ORIG ALL=NOPASSWD: /bin/chown -R $USER_ORIG\:$USER_ORIG /etc/NetworkManager/system-connections/" | sudo tee -a /etc/sudoers.d/$USER_ORIG
sudo echo "%$USER_ORIG ALL=NOPASSWD: /bin/chown -R root\:root /etc/NetworkManager/system-connections/" | sudo tee -a /etc/sudoers.d/$USER_ORIG

nmcli connection import type openvpn file ~/Downloads/$config
nmcli connection modify $name +vpn.data username=$user

sudo chown -R $USER_ORIG:$USER_ORIG /etc/NetworkManager/system-connections/

sed -i -e "s/.*password-flag.*/password-flags=0/" /etc/NetworkManager/system-connections/$name.nmconnection

echo "[vpn-secrets]" >> /etc/NetworkManager/system-connections/$name.nmconnection
echo "password=$PW_OPNVPN" >> /etc/NetworkManager/system-connections/$name.nmconnection

sudo chown -R root:root /etc/NetworkManager/system-connections/

sudo systemctl restart NetworkManager

sleep 10

nmcli con up id $name
