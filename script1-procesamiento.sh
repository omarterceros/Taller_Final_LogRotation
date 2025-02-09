#!/bin/bash

#Verifica si se han proporcionado dos fechas como parámetros
if [ "$#" -ne 2 ]; then
    echo "Uso: $0 YYYY-MM-DD_INICIO YYYY-MM-DD_FIN"
    exit 1
fi

DATE_START=$1
DATE_END=$2

#Obtén la fecha y hora actuales
ORIGINAL_DATE=$(date '+%Y-%m-%d %H:%M:%S')



#Definir carpeta de exportación
BASE_EXPORT_DIR="./data_logs"

#Crear carpeta base de exportación si no existe
mkdir -p "$BASE_EXPORT_DIR"

#Función para crear un directorio si no existe
create_directory() {
    local DIR=$1
    mkdir -p "$DIR"
}


# Función para copiar el contenido del archivo de log a un nuevo archivo
copy_log_content() {

    local LOGFILE_PATH=$1
    local OUTPUT_FILE=$2

    cp "$LOGFILE_PATH" "$OUTPUT_FILE"

}

# Función para comprimir un archivo log y eliminar el archivo original
compress_and_remove() {

    local OUTPUT_FILE=$1
    local DATE=$2

    tar -czf "${OUTPUT_FILE}.tar.gz" -C "$(dirname "$OUTPUT_FILE")" "$(basename "$OUTPUT_FILE")"
    rm "$OUTPUT_FILE"
    touch -t "$(echo $DATE | sed 's/-//g')2359" "${OUTPUT_FILE}.tar.gz"
}


# Función para formatear la fecha en YYYY-MM-DD
format_date() {
    local DATE=$1
    echo "$DATE"
}

#Función para convertir fecha en formato YYYY-MM-DD & YYYYMMDD
convert_date() {
    local DATE=$1
    echo "$DATE" | sed 's/-//g'
}

#Función para procesar un archivo de log con una fecha especifica
process_log_file() {

    local LOGFILE_PATH=$1
    local DATE_STR=$2

    local BASENAME=$(basename "$LOGFILE_PATH" .log)
    local OUTPUT_DIR="$BASE_EXPORT_DIR/${BASENAME}_data_logs"

    local FORMATTED_DATE=$(format_date "$DATE_STR")
    local CONVERTED_DATE=$(convert_date "$DATE_STR")

    create_directory "$OUTPUT_DIR"

    #Genera el nombre del archivo de salida
    local OUTPUT_FILE="$OUTPUT_DIR/${BASENAME}_${CONVERTED_DATE}.log"

    #Cambia La fecha y hora del sistema automáticamente con la contraseña
    echo "ortiz" | sudo -S date -s "$DATE_STR 23:59:00"


    # Copia el contenido del archivo de log al nuevo archivo
    copy_log_content "$LOGFILE_PATH" "$OUTPUT_FILE"

    # Cambia la fecha de modificación y de acceso del archivo
    touch -t "$(echo $DATE_STR | sed 's/-//g')2359" "$OUTPUT_FILE"

    local LINE_COUNT=$(wc -l < "$OUTPUT_FILE")

    if [ "$LINE_COUNT" -gt 0 ]; then
        echo "Se han copiado $LINE_COUNT lineas en $OUTPUT_FILE."

        compress_and_remove "$OUTPUT_FILE" "$FORMATTED_DATE"
        echo "El archivo ha sido comprimido a ${OUTPUT_FILE}.tar.gz y el archivo original log ha sido eliminado."

    else
        echo "No se encontraron lineas en $LOGFILE_PATH."
        rm "$OUTPUT_FILE"

    fi

    # Restaura la fecha y hora originales del sistema automáticamente
    echo "ortiz" | sudo -S date -s "$ORIGINAL_DATE"
}

# Función para iterar sobre un rango de fechas
iterate_date_range() {

    local START_DATE=$1
    local END_DATE=$2

    local CURRENT_DATE=$START_DATE

    while [ "$CURRENT_DATE" != "$(date -I -d "$END_DATE + 1 day")" ]; do

        process_log_file "logs/Android_2k.log" "$CURRENT_DATE"
        process_log_file "logs/Apache_2k.log" "$CURRENT_DATE"
        process_log_file "logs/Linux_2k.log" "$CURRENT_DATE"
        process_log_file "logs/Mac_2k.log" "$CURRENT_DATE"
        process_log_file "logs/Windows_2k.log" "$CURRENT_DATE"

        CURRENT_DATE=$(date -I -d "$CURRENT_DATE + 1 day")

    done

}

# Itera sebre el rango de fechas proporcionado
iterate_date_range "$DATE_START" "$DATE_END"