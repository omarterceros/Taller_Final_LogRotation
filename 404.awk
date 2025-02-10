#!/usr/bin/awk -f

BEGIN {
    print "Análisis de Errores 404 en Apache"
    print "================================"
    print strftime("%Y-%m-%d %H:%M:%S")
    print ""
    total = 0
    print "Tiempo                   | IP               | URL                 | User Agent"
    print "-------------------------|------------------|--------------------|-----------------"
}

/HTTP\/1.0" 404/ {
    total++
    timestamp = $4 " " $5
    ip = $1
    url = $7
    userAgent = $12 " " $13 " " $14
    printf "%-24s | %-16s | %-18s | %s\n", timestamp, ip, url, userAgent
}

END {
    print "\nResumen:"
    print "--------"
    print "Total de errores 404:", total
    if (total > 0) {
        print "Tasa de errores por línea:", total/NR * 100 "%"
        print "\nDistribución por hora:"
        for (hour in hourly_count) {
            printf "%02d:00 - %02d:59: %d errores\n", hour, hour, hourly_count[hour]
        }
    }
}