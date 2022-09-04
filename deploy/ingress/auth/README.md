# Add authoration for ingress
## Create a auth cert with secret
- htpasswd -c auth foo
  
- kubectl create secret generic basic-auth --from-file auth
## Add ingress auth 
update nginx-test annotations 
nginx.ingress.kubernetes.io/auth-type: basic
nginx.ingress.kubernetes.io/auth-secret: basic-auth
nginx.ingress.kubernetes.io/auth-realm: 'Authentication Required - foo'