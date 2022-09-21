FROM nginx
ENV login /usr/share/nginx/html
ENV config /etc/nginx/conf.d
WORKDIR $login
ADD assests $login/assests
ADD css $login/css
ADD fonts $login/fonts
ADD index.html $login/index.html
ADD login.conf $config/login.conf 
EXPOSE 80
CMD [ "nginx","-g","daemon off;" ]