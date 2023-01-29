
# Grab the external IP from MetalLB
lb_ip=$(kubectl --namespace ingress-nginx get service/ingress-nginx-controller -o=jsonpath='{.status.loadBalancer.ingress[0].ip}')

# Get all create resources and out
kubectl --namespace ingress-nginx get all

echo
echo Now register a wildcard DNS entry like \*.k8s01.hpedemo.local = $lb_ip
