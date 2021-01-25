#!/bin/bash

INPUT=errores.csv
OLDIFS=$IFS
IFS=','

[ ! -f $INPUT ] && { echo "$INPUT file not found"; exit 99; }
while read Presion Temperatura
do
	echo "Pressure : $Presion Temperature : $Temperatura"

done < $INPUT
IFS=$OLDIFS
