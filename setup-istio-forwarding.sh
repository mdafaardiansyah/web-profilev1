#!/bin/bash

# Flush any existing rules
iptables -t nat -F

# Forward port 80 to Istio HTTP nodeport
iptables -t nat -A PREROUTING -p tcp --dport 80 -j REDIRECT --to-port 32636

# Forward port 443 to Istio HTTPS nodeport
iptables -t nat -A PREROUTING -p tcp --dport 443 -j REDIRECT --to-port 32697

# Save the rules
iptables-save > /etc/iptables/rules.v4

echo "Port forwarding has been set up for Istio Ingress Gateway"