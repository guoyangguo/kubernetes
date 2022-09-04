# Ingress config https
## Create CA
openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout tls.key -out tls.crt -subj "/CN=foo.bar.com"
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