#!/bin/bash

#
#    Author: Sarven Capadisli <info@csarven.ca>
#    Author URI: http://csarven.ca/#i
#

. ./frb.config.sh

mkdir -p "$data"import ;
rm "$data"import/*.nt ;

ls -1 "$data"*.rdf | grep -E "struct|prov" | while read i ; do file=$(basename "$i"); dataSetCode=${file%.*}; rapper -g "$i" > "$data"import/"$dataSetCode".nt ; done

#This is fugly!
while read j ; do find "$data" -name "$j*[!struct|prov].rdf" | while read i ; do file=$(basename "$i"); dataSetCode=${file%.*}; rapper -g "$i" >> "$data"import/"$j".nt ; done ; done < "$data"../scripts/"$agency".data.txt

#real    45m2.094s
#user    42m16.820s
#sys     0m53.200s

