#!/bin/bash
inverso=false
alpha=false
linhas=-1

while getopts ":ral:" opt; do
    case $opt in
        r)
            reverse_sort=true
            ;;
        a)
            alphabetical_sort=true
            ;;
        l)
            linhas="$OPTARG"
            ;;
        \?)
            echo "Opção inválida: -$OPTARG" >&2
            exit 1
            ;;
        :)
            echo "Opção -$OPTARG requer um argumento." >&2
            exit 1
            ;;
    esac
done
shift $((OPTIND-1))
f1="$1"
f2="$2"

sort_options=""

# Set default sorting options based on size in descending order
sort_options="-r -g -k1"

# Modify sort_options based on user input
if [ "$alphabetical_sort" = true ]; then
    sort_options="${sort_options} -k2"
fi

if [ "$reverse_sort" = true ]; then
    # If reverse_sort is true, remove the default reverse order option
    sort_options="$(echo $sort_options | sed 's/-r //')"
fi

printf "%-10s %s\n" "SIZE" "NAME"


# Merge the output of both loops and sort them
{
    while IFS= read -r line; do
        name2=$(echo "$line" | awk '{print $2}')
        size2=$(echo "$line" | awk '{print $1}')
        
        # Verificar se name2 não está presente no primeiro ficheiro
        if ! grep -q "$name2" "$f1"; then
            printf "%-10s %s\n" "$size2" "$name2 NEW"
        fi
    done < "$f2"

    while IFS= read -r line || [[ -n "$line" ]]; do
        #se a primeira linha contiver a palavra "SIZE" ignorar
        if [[ "$line" == *"SIZE"* ]]; then
            continue
        fi
        #guardar name e size da linha do primeiro ficheiro em variáveis
        name1=$(echo "$line" | awk '{print $2}')
        size1=$(echo "$line" | awk '{print $1}')
        #procurar name1 no segundo ficheiro usando awk, se encontrar usando grep guardar o size na variável size2 e imprimir a diferença dos size e o name do arquivo, se não encontrar imprimir a diferença negativa o name do arquivo e "REMOVED"
        size2=$(awk -v name="$name1" '$2 == name {print $1}' "$f2")
        if grep -q "$name1" "$f2"; then
            printf "%-10s %s\n" "$((size1 - size2))" "$name1"
        else
            printf "%-10s %s\n" "$((size1 * -1))" "$name1 REMOVED"
        fi
    done < "$f1"
} | sort $sort_options | if [ "$linhas" = -1 ]; then cat; else head -n "$linhas"; fi




