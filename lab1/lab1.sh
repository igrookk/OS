#!/bin/bash

TASKID=9

# Динамически считаем общее количество строк
VAR_1=$(wc -l < dns-tunneling.log)

# Берём строки с 15 по 30 (включительно)
LINES=$(sed -n '15,30p' dns-tunneling.log)

# Формируем JSON в файл results.txt
{
    echo '{'
    echo -e '\t"dnslog": ['
    
    # Обрабатываем строки, преобразуем в JSON-объекты
    
    echo "$LINES" | awk '
    BEGIN {
        indent = "\t\t"
        first = 1
    }
    {        
        timestamp = $1
        client_ip = $2
        
        # Для url возьмём всё начиная с третьего поля до конца строки
        url = ""
        for(i=3; i<=NF; i++) {
            url = url $i
            if(i<NF) url = url " "
        }
        
        # Экранируем двойные кавычки в url
        gsub(/"/, "\\\"", url)
        
        if (first == 0) {
            print ","
        } else {
            first = 0
        }
        
        print indent "{"
        print indent "\t\"timestamp\": \"" timestamp "\","
        print indent "\t\"client ip\": \"" client_ip "\","
        print indent "\t\"url\": \"" url "\""
        print indent "}"
    }
    END {
        print ""
    }
    '
    
    echo -e '\t]'
    echo '}'
} > results.txt

# Подсчитываем количество записей с поддоменами 1yf.de. или 2yf.de.
# grep ищет совпадения, wc -l считает строки
VAR_2=$(grep -E '([0-9a-zA-Z.-]+\.)?(1yf\.de\.|2yf\.de\.)' results.txt | wc -l)

echo "Общее количество записей в dns-tunneling.log: $VAR_1"
echo "Количество записей с поддоменами 1yf.de. и 2yf.de.: $VAR_2"
