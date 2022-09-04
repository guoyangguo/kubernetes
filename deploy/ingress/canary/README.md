# Canary
## priority request-header > cookie > weight
## Create production  
kubectl apply -f production.yaml
kubectl apply -f production-ingress.yaml
## Base on weight
create canary version base on production version and update 'production' to 'canary'
kubectl apply -f canary.yaml
kubectl apply -f canary-ingress.yaml
sh testing test-canary-weight.sh

## Base on request-header
add annotations:
    kubernetes.io/ingress.class: nginx 
    nginx.ingress.kubernetes.io/canary: "true"   # 要开启灰度发布机制，首先需要启用 Canary
    nginx.ingress.kubernetes.io/canary-by-header: "version" # 根据request-header 来切分(version:v1.2.0)
    nginx.ingress.kubernetes.io/canary-by-header-value: "v1.2.0"
## Base on cookie
add annotations:
    kubernetes.io/ingress.class: nginx 
    nginx.ingress.kubernetes.io/canary: "true"
    nginx.ingress.kubernetes.io/canary-by-cookie: "beijing" # 根据request-header 来切分(version:v1.2.0)
    nginx.ingress.kubernetes.io/weight: "30"