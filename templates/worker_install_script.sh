touch /etc/initialized

if [[ $(< /etc/initialized) != "true" ]]; then
  systemctl restart NetworkManager || true
  dhclient eth1 -v || true
fi

HOSTNAME=$(hostname -f)
PRIVATE_IP=$(ip route get 10.0.0.1 | awk -F"src " 'NR==1{split($2,a," ");print a[1]}')
PUBLIC_IP=$(hostname -I | awk '{print $1}')
NETWORK_INTERFACE=$(ip route get 10.0.0.1 | awk -F"dev " 'NR==1{split($2,a," ");print a[1]}')
PRIVATE_IP6=$(ip -6 addr show dev ${NETWORK_INTERFACE} scope link | awk -F"inet6 " 'NR==2{split($2,a,"/");print a[1]}')
PUBLIC_IP6=$(ip -6 addr show scope global | awk -F"inet6 " 'NR==2{split($2,a,"/");print a[1]}')

curl -sfL https://get.k3s.io | K3S_TOKEN="{{ k3s_token }}" INSTALL_K3S_VERSION="{{ k3s_version }}" K3S_URL=https://{{ first_master_private_ip_address }}:6443 INSTALL_K3S_EXEC="agent \
--node-name=$HOSTNAME \
--kubelet-arg="cloud-provider=external" \
--node-ip=$PRIVATE_IP,$PRIVATE_IP6 \
--node-external-ip=$PUBLIC_IP,$PUBLIC_IP6 \
--flannel-iface=$NETWORK_INTERFACE" sh -

systemctl start k3s-agent # on some OSes the service doesn't start automatically for some reason

echo true > /etc/initialized
