# Install ingress-nginx with helm
## Add repo
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
## Get chart
helm pull ingress-nginx/ingress-nginx v3.15.2
tar -vxf ingress-nginx-3.15.2.tgz
## Install chart
value-prod.yaml override dafault value.yaml
helm install ingress-nginx -n ingress-nginx ./ingress-nginx -f ./ingress-nginx/value-prod.yaml