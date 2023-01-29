#!/bin/bash

# create the namespace
kubectl create namespace ingress-nginx

helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo update

# create secret with wildcard cert
kubectl create secret tls hpedemo-local-wildcardcert --namespace ingress-nginx \
    --key k8s01-key.pem \
    --cert k8s01-cert.pem
   
# create secret with wildcard cert
kubectl create secret tls hpedemo-local-wildcardcert --namespace demo-ingress \
    --key k8s01-key.pem \
    --cert k8s01-cert.pem

# install ingress-nginx and use the secret
# Only specifying LoadBalancer require something like MetalLB install 
helm install ingress-nginx ingress-nginx/ingress-nginx --namespace ingress-nginx \
  --set controller.defaultTLS.secret=ingress-nginx/hpedemo-local-wildcardcert \
  --set controller.wildcardTLS.secret=ingress-nginx/hpedemo-local-wildcardcert \
  --set controller.service.type=LoadBalancer

  #--set controller.service.loadBalancerIP=10.0.0.1
