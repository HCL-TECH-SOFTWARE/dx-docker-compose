openssl genrsa -out tls.key 2048
openssl req -new -key tls.key -out tls.csr
openssl x509 -req -days 358000 -in tls.csr -signkey tls.key -out tls.crt
cat tls.key tls.crt > localhost.pem
