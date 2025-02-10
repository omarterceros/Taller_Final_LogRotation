#!/bin/bash

# Configuración de correo
ADMIN_EMAIL="omar.tercerov@gmail.com"
APP_PASSWORD="edf4asdg1"

# Instalar postfix y mailutils
sudo apt-get update
sudo apt-get install -y postfix mailutils

# Configurar postfix para usar Gmail
sudo postconf -e "relayhost = [smtp.gmail.com]:587"
sudo postconf -e "smtp_use_tls = yes"
sudo postconf -e "smtp_sasl_auth_enable = yes"
sudo postconf -e "smtp_sasl_password_maps = hash:/etc/postfix/sasl_passwd"
sudo postconf -e "smtp_sasl_security_options = noanonymous"
sudo postconf -e "smtp_tls_CAfile = /etc/ssl/certs/ca-certificates.crt"

# Crear archivo de credenciales
echo "[smtp.gmail.com]:587 $ADMIN_EMAIL:$APP_PASSWORD" | sudo tee /etc/postfix/sasl_passwd > /dev/null

# Proteger el archivo de credenciales
sudo chmod 600 /etc/postfix/sasl_passwd

# Crear base de datos de contraseñas
sudo postmap /etc/postfix/sasl_passwd

# Reiniciar postfix
sudo systemctl restart postfix

# Enviar correo de prueba
echo "Este es un correo de prueba del sistema