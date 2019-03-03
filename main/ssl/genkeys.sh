#!/bin/bash
set -e
set -x

b=2048 # RSA Key bits
n=3650 # Days of certificate validity

subj="/C=US/ST=CA/L=Mountain View/O=Google/OU=Google Cloud"

# Use SHA256 for all signatures
# https://security.googleblog.com/2014/09/gradually-sunsetting-sha-1.html

# Create CA key
openssl genrsa $b > ca.pem
# Create CA certificate
openssl req -new -x509 -sha256 -nodes -days $n -key ca.pem -out ca.crt -subj "$subj/CN=tempca"
# Print certificate
openssl x509 -in ca.crt -text -noout

# Generate key and signed certificate for a given node
sign_cert () {
  x=$1
  # Create certificate signing request
  openssl req -newkey rsa:$b -days $n -nodes -keyout $x.pem -out $x.csr -subj "$subj/CN=$x"
  # Sign certificate with CA private key
  openssl x509 -req -sha256 -in $x.csr -days $n -CA ca.crt -CAkey ca.pem -set_serial 01 -out $x.crt
  rm $x.csr
  # Verify certificate
  openssl verify -CAfile ca.crt $x.crt
  # Print certificate
  openssl x509 -in $x.crt -text -noout
}

# Create keys and certificates for cluster nodes 
for i in {0..3}; do
  sign_cert "$i"
done
sign_cert garb

# Delete the CA private key so it can't be used again
rm -v ca.pem
