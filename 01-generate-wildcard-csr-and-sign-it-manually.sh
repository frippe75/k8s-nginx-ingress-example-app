# Requires OpenSSL 1.1.1 for the -addext option and that the fqdn is added to DNS prior to running
set -oe pipefail

fqdn=k8s01.hpedemo.local
country=SE;ou=MY-OU;st=Stockholm;loc=Stockholm;org="My Org"
hostname=$(echo $fqdn | cut -f 1 -d '.')
#ip=$(getent hosts $fqdn | awk '{print $1}')

#echo $fqdn
#echo $hostname
#echo $ip

openssl req \
  -nodes \
  -addext "subjectAltName = DNS.1:$fqdn,DNS.2:*.$fqdn,DNS.3:$hostname" \
  -addext "certificatePolicies = 1.2.3.4" \
  -newkey rsa:4096 \
  -keyout $hostname-key.pem \
  -out $hostname-cert.csr -subj "/C=${country}/ST=${st}/L=${loc}/O=${org}/OU=${ou}/CN=${fqdn}"
