#!/bin/bash
#Cabecalho com data formatada
dt=$(date +%Y%m%d)
echo "SIZE    NAME" $dt $*
#a = ultimo argumento
for i in "$@"; do
    a=$i
done
#oplist seleciona os ficheiros a contabilizar
oplist="du -a -b"
#opdate decide se o codigo para selecionar ficheiros com base na data e executado
opdate=0
#opsort seleciona o modo de ordenacao do output
opsort="-g -r"
#opprint seleciona o numero de linhas a imprimir no output
opprint="cat"
#opcoes/flags
while getopts "n:d:s:al:r" op; do
    case ${op} in
    n)
        n=${OPTARG}
        oplist="$oplist --exclude=$n"
        ;;
    d)
        d=${OPTARG}
        #Conversao da data passada como argumento em segundos
        mdate=$(date -d "$d" "+%s")
        #Listar com data de modificacao em segundos para depois selecionar os ficheiros com base nesta
        oplist="$oplist --time --time-style=+%s"
        opdate=1
        ;;
    s)
        s=${OPTARG}
        oplist="$oplist -t $s"
        ;;
    a)
        opsort="-d -f -k 2"
        ;;
    l)
        l=${OPTARG}
        opprint="head -n $l"
        ;;
    r)
        opsort="-g"
        ;;
    esac
done
#Listar diretorio e subdiretorios a analisar
du -b $a >> auxfile.txt
#Para cada diretorio, calcular e registar o espaco ocupado
for d in $(awk '{print $2}' auxfile.txt); do
    #Listar apenas os ficheiros que interessam
    $oplist $d>>auxfile2.txt
    #Codigo da flag -d
    if (($opdate==1)); then
        #Garantir que o ficheiro com as datas existe, mesmo que o diretorio nao tenha datas a contabilizar
        touch auxfile4.txt
        #Listar apenas as datas que interessam
        for i in $(awk '{print $2}' auxfile2.txt); do
            if ((i<=$mdate));then
                echo $i >> auxfile4.txt
            fi
        done
        #Com base na lista de datas, listar apenas os ficheiros que tem essas datas
        grep -f auxfile4.txt auxfile2.txt >> auxfile3.txt
        rm auxfile4.txt
        rm auxfile2.txt
        #Remover as datas de modificacao da lista de ficheiros
        awk '{print $1 "\t" $3}' auxfile3.txt >> auxfile2.txt
        rm auxfile3.txt
    fi
    spacecount=0;
    #Garantir que o ficheiro com os ficheiros a contabilizar existe, mesmo que o diretorio nao tenha ficheiros a contabilizar
    touch auxfile3.txt
    #Lista de ficheiros a contabilizar, sem diretorios
    for i in $(awk '{print $2}' auxfile2.txt); do
        if [[ -f $i ]]; then
            echo $i>>auxfile3.txt
        fi
    done
    #Lista de ficheiros a contabilizar e respetivo espaco ocupado
    grep -f auxfile3.txt auxfile2.txt >> auxfile4.txt
    rm auxfile2.txt
    rm auxfile3.txt
    #Calcular o espaco ocupado
    for i in $(awk '{print $1}' auxfile4.txt); do
        spacecount=$(($spacecount+$i))
    done
    rm auxfile4.txt
    #Imprimir o espaco ocupado e respetivo diretorio
    printf "%d\t%s\n" $spacecount $d >> auxfile5.txt
done
rm auxfile.txt
#Ordenar do output
sort $opsort auxfile5.txt >> sortedauxfile.txt
rm auxfile5.txt
#Imprimir o output
$opprint sortedauxfile.txt
rm sortedauxfile.txt