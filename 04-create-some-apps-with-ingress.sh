#!/bin/bash


# Generate a IMDB type app with ingress and TLS termination via the NGINX controller with MetalLB as LoadBalancer
./app-with-two-services-using-ingress.sh imdb movies2 reviews2

# Generate a Shopping type app with ingress and TLS termination via the NGINX controller with MetalLB as LoadBalancer
./app-with-two-services-using-ingress.sh store cart customers
