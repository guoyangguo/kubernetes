# Canary
## Create production  
kubectl apply -f production.yaml
kubectl apply -f production-ingress.yaml
## Base on weight
create canary version base on production version and update 'production' to 'canary'
kubectl apply -f canary.yaml
kubectl apply -f canary-ingress.yaml
sh testing test-canary-weight.sh

## Base on request-header
## Base on 