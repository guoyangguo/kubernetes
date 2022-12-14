# Ingress config https
## Create CA
openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout tls.key -out tls.crt -subj "/CN=login.autumnin.com"
## Create secret with CA
kubectl create secret tls  foo-tls --cert=tls.crt --key=tls.key
## Update ingress
``` yaml
spec:
  rules:
  - host: ng.autumn.com
    http:
      paths:
      - path: "/"
        backend:
          serviceName: ingress-with-https
          servicePort: web
  tls:
    - hosts:
        - ng.autumn.com
      secretName: foo-tls
```
## Config with cert-manager
### install cert-manager
``` shell
# Kubernetes 1.16+
kubectl apply -f https://github.com/jetstack/cert-manager/releases/download/v1.1.0/cert-manager.yaml
# Kubernetes <1.16
kubectl apply --validate=false -f https://github.com/jetstack/cert-manager/releases/download/v1.1.0/cert-manager-legacy.yaml
```