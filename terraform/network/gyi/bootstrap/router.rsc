/interface/vlan/add name=bootstrap0 interface=ether2 vlan-id=2
/ip/address/add address=100.64.1.1/24 interface=bootstrap0
/certificate
add name=ca common-name=local_ca key-usage=key-cert-sign
add name=self common-name=localhost
sign ca
sign self
/ip service
set www disabled=no
set www-ssl certificate=self disabled=no
