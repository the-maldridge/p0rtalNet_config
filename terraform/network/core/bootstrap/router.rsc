/interface/vlan/add comment="Bootstrap Interface" interface=ether1 name=bs0 vlan-id=2
/ip/address/add address=100.64.1.1/24 interface=bs0
/ip/dhcp-client/add interface=ether1 disabled=no add-default-route=no use-peer-dns=no use-peer-ntp=no
/certificate
add name=ca common-name=local_ca key-usage=key-cert-sign
add name=self common-name=localhost
sign ca
sign self
/ip service
set www disabled=no
set www-ssl certificate=self disabled=no
