# Rotación diaria de logs (23:59)
59 23 * * * /ruta/absoluta/scrip1-procesamiento.sh >> /var/log/script2-transferencia.log 2>&1

# Transferencia mensual (23:59 último día del mes)
59 23 28-31 * * [ "$(date -d '+1 day' +\%d)" = "01" ] && /ruta/absoluta/script2-transferencia.sh >> /var/log/script2-transferencia.log 2>&1

# Análisis de errores 404 (cada hora)
0 * * * * /ruta/absoluta/404.awk /ruta/absoluta/logs/apache/Apache_2k.log | mail -s "Reporte Horario Apache 404" omar.tercerov@gmail.com