# TEMPLATE for /etc/nginx/nginx.conf

daemon off;
user nginx;
worker_processes 1;

error_log  /var/log/nginx/error.log info;
pid        /var/run/nginx.pid;

events {
    worker_connections  1024;
}

http {
    include       /etc/nginx/mime.types;
    default_type  application/octet-stream;

    log_format  main  '$remote_addr - $remote_user [$time_local] "$request" '
                      '$status $body_bytes_sent "$http_referer" '
                      '"$http_user_agent" "$http_x_forwarded_for" => $upstream_addr';

    access_log /var/log/nginx/access.log main;

    sendfile        on;
    #tcp_nopush     on;

    keepalive_timeout  65;

    #gzip on;

	server {
		listen 80 default_server;
		listen [::]:80 default_server;
		server_name ${FQDN};

		return 301 https://$server_name$request_uri;
	}

	server {
	    listen 443 default_server ssl;

	    ssl_certificate            ${CERTPATH}/fullchain.pem;
	    ssl_certificate_key        ${CERTPATH}/privkey.pem;

	    ssl_session_cache builtin:1000 shared:SSL:10m;
	    ssl_session_timeout 180m;

	    ssl_protocols  TLSv1 TLSv1.1 TLSv1.2;

	    ssl_ciphers 'ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-AES256-GCM-SHA384:DHE-RSA-AES128-GCM-SHA256:DHE-DSS-AES128-GCM-SHA256:kEDH+AESGCM:ECDHE-RSA-AES128-SHA256:ECDHE-ECDSA-AES128-SHA256:ECDHE-RSA-AES128-SHA:ECDHE-ECDSA-AES128-SHA:ECDHE-RSA-AES256-SHA384:ECDHE-ECDSA-AES256-SHA384:ECDHE-RSA-AES256-SHA:ECDHE-ECDSA-AES256-SHA:DHE-RSA-AES128-SHA256:DHE-RSA-AES128-SHA:DHE-DSS-AES128-SHA256:DHE-RSA-AES256-SHA256:DHE-DSS-AES256-SHA:DHE-RSA-AES256-SHA:AES128-GCM-SHA256:AES256-GCM-SHA384:AES128-SHA256:AES256-SHA256:AES128-SHA:AES256-SHA:AES:CAMELLIA:DES-CBC3-SHA:!aNULL:!eNULL:!EXPORT:!DES:!RC4:!MD5:!PSK:!aECDH:!EDH-DSS-DES-CBC3-SHA:!EDH-RSA-DES-CBC3-SHA:!KRB5-DES-CBC3-SHA';

	    ssl_prefer_server_ciphers on;
	    ssl_dhparam /etc/nginx/dhparams.pem;
		add_header Strict-Transport-Security "max-age=31536000" always;

		# locations

		include /etc/nginx/locations-enabled/*.conf;

	}
}
