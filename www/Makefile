
LOCALBASE=/usr/local

SERVICE=/usr/sbin/service


NGINX_CONFIG= nginx.conf


all:

install: install-conf 


install-conf: ${NGINX_CONFIG}
	${INSTALL} -o root -g wheel -m 644 $> ${LOCALBASE}/etc/nginx

reload:
	${SERVICE} nginx reload 

restart:
