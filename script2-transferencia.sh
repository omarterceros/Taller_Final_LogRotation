#!/bin/bash

# Definir IP de Fedora automáticamente
IP_FEDORA="192.168.0.10"

# Definir usuario y contraseña en Fedora
USUARIO_FEDORA="ortiz"
PASSWORD_FEDORA="ortiz"

# Definir la ruta base en Fedora
RUTA_BASE="/home/ortiz/Repositorio"

# Definir la carpeta base donde están los logs en Ubuntu
DATA_LOGS="data_logs"

# Definir las carpetas a transferir
CARPETAS=(
  "Android_2k_data_logs"
  "Apache_2k_data_logs"
  "Linux_2k_data_logs"
  "Mac_2k_data_logs"
  "Windows_2k_data_logs"
)

# Verificar si sshpass está instalado
if ! command -v sshpass &>/dev/null; then
  echo "Error: sshpass no está instalado. Instálalo con: sudo apt install sshpass"
  exit 1
fi

# Función para crear la subcarpeta del año y mes en Fedora
create_yearly_monthly_folder() {
  local BASE_FOLDER="$1"
  local FILE="$2"

  local DATE=$(echo "$FILE" | grep -oP '\d{8}')
  local YEAR=$(echo "$DATE" | cut -c1-4)
  local MONTH=$(echo "$DATE" | cut -c5-6)

  local YEAR_FOLDER="${RUTA_BASE}/${BASE_FOLDER}/${YEAR}"
  local MONTH_FOLDER="${YEAR_FOLDER}/${MONTH}"

  echo "Creando subcarpeta del año en Fedora: ${YEAR_FOLDER}..."
  sshpass -p"$PASSWORD_FEDORA" ssh -o StrictHostKeyChecking=no ${USUARIO_FEDORA}@${IP_FEDORA} "mkdir -p ${YEAR_FOLDER}"

  echo "Creando subcarpeta del mes en Fedora: ${MONTH_FOLDER}..."
  sshpass -p"$PASSWORD_FEDORA" ssh -o StrictHostKeyChecking=no ${USUARIO_FEDORA}@${IP_FEDORA} "mkdir -p ${MONTH_FOLDER}"
}

# Función para transferir archivos de una carpeta a Fedora
transfer_files() {
  local BASE_FOLDER="$1"

  for FILE in "${DATA_LOGS}/${BASE_FOLDER}"/*.tar.gz; do
    if [ -f "$FILE" ]; then
      local FILENAME=$(basename "$FILE")
      create_yearly_monthly_folder "$BASE_FOLDER" "$FILENAME"

      local DATE=$(echo "$FILENAME" | grep -oP '\d{8}')
      local YEAR=$(echo "$DATE" | cut -c1-4)
      local MONTH=$(echo "$DATE" | cut -c5-6)
      local DEST_DIR="${RUTA_BASE}/${BASE_FOLDER}/${YEAR}/${MONTH}"

      echo "Transfiriendo archivo ${FILE} a Fedora en ${DEST_DIR}..."
      sshpass -p "$PASSWORD_FEDORA" scp "$FILE" "${USUARIO_FEDORA}@${IP_FEDORA}:${DEST_DIR}"

      if [ $? -eq 0 ]; then
        echo "Eliminando archivo ${FILE} de Ubuntu..."
        rm "$FILE"
      else
        echo "Error en la transferencia del archivo ${FILE}. No se eliminará."
      fi
    else
      echo "No se encontraron archivos en la carpeta ${DATA_LOGS}/${BASE_FOLDER}."
    fi
  done
}


# Función para eliminar carpetas vacías
delete_empty_directories() {
  local BASE_FOLDER="$1"
  find "${DATA_LOGS}/${BASE_FOLDER}" -type d -empty -delete
}

# Función para transferir una carpeta a Fedora
transfer_folder() {
  local FOLDER="$1"

  echo "Creando directorio en Fedora: ${RUTA_BASE}/${FOLDER}..."
  sshpass -p "$PASSWORD_FEDORA" ssh ${USUARIO_FEDORA}@${IP_FEDORA} "mkdir -p ${RUTA_BASE}/${FOLDER}"

  transfer_files "$FOLDER"
  delete_empty_directories "$FOLDER"

  echo "Transferencia de ${FOLDER} completada."
}

# Itera sobre cada carpeta y transfiérela
for CARPETA in "${CARPETAS[@]}"; do
  if [ -d "${DATA_LOGS}/${CARPETA}" ]; then
    transfer_folder "$CARPETA"
  else
    echo "La carpeta ${DATA_LOGS}/${CARPETA} no existe en el directorio actual."
  fi
done