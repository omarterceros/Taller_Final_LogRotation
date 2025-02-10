#!/bin/bash

# Directorio base
BASE_DIR=$(pwd)

# Crear estructura de directorios
mkdir -p logs/{android,linux,apache,mac,windows}
mkdir -p data_logs

# Establecer permisos
chmod +x scrip1-procesamiento.sh.sh
chmod +x script2-transferencia.sh
chmod +x 404_.awk
chmod +x email.sh

# Configurar rutas en crontab
sed -i "s|/ruta/absoluta|$BASE_DIR|g" crontab.sh

# Instalar crontab
crontab crontab.sh

# Configurar correo
./setup_email.sh

echo "Configuración completada. Sistema de logs iniciado."