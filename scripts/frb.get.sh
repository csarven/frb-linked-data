#!/bin/bash

#
#    Author: Sarven Capadisli <info@csarven.ca>
#    Author URI: http://csarven.ca/#i
#

. ./frb.config.sh

rm "$data""$agency".prov.retrieval.rdf

baseURL="http://www.federalreserve.gov/DataDownload/"

wget "$baseURL" -O frb.html
sed -ri 's/&nbsp;/  /g' frb.html && sed -ri 's/ & /\&#38;/' frb.html
xmllint --format frb.html | grep -E "href=\"Choose.aspx" | perl -pe 's/([^<]*)(.*)/$2/' | sort -u > frb.temp


echo '<?xml version="1.0" encoding="UTF-8"?>
<rdf:RDF
    xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
    xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#"
    xmlns:dcterms="http://purl.org/dc/terms/"
    xmlns:prov="http://www.w3.org/ns/prov#"
    xmlns:foaf="http://xmlns.com/foaf/0.1/"
    xmlns:sdmx="http://purl.org/linked-data/sdmx#">' > "$data""$agency".prov.retrieval.rdf ;

Get=(Data DataStructure);

counter=1;
while read i ;
    do
        DataSetCode=$(echo "$i" | perl -pe 's/<a href=\"Choose.aspx\?rel=([^\"]*)\"(.*)/\1/');

        downloadURL="$baseURL""Output.aspx?rel=$DataSetCode&filetype=zip"

        dtstart=$(date +"%Y-%m-%dT%H:%M:%SZ") ;
        dtstartd=$(echo "$dtstart" | sed 's/[^0-9]*//g') ;

        wget -c -t 1 --no-http-keep-alive "$downloadURL" -O "$data""FRB_""$DataSetCode"".zip"
#        sleep 1

        dtend=$(date +"%Y-%m-%dT%H:%M:%SZ") ;
        dtendd=$(echo "$dtend" | sed 's/[^0-9]*//g') ;

        downloadURL=$(echo "$downloadURL" | sed 's/&/\&amp;/');

        for GD in "${Get[@]}" ;
            do
                echo "$counter $DataSetCode $GD" ;

                if [ "$GD" == "Data" ]
                then
                    DataType="http:\/\/purl.org\/linked-data\/sdmx#DataSet"
                    DataTypeLabel="Data"
                    DataTypePath="_data"
                else
                    DataType="http:\/\/purl.org\/linked-data\/sdmx#DataStructureDefinition"
                    DataTypeLabel="Structure"
                    DataTypePath="_struct"
                fi

#        sleep 1
                echo '
                <rdf:Description rdf:about="http://frb.270a.info/provenance/activity/'$dtstartd'">
                    <rdf:type rdf:resource="http://www.w3.org/ns/prov#Activity"/>
                    <prov:startedAtTime rdf:datatype="http://www.w3.org/2001/XMLSchema#dateTime">'$dtstart'</prov:startedAtTime>
                    <prov:endedAtTime rdf:datatype="http://www.w3.org/2001/XMLSchema#dateTime">'$dtend'</prov:endedAtTime>
                    <prov:wasAssociatedWith rdf:resource="http://csarven.ca/#i"/>
                    <prov:used rdf:resource="https://launchpad.net/ubuntu/+source/wget"/>
                    <prov:used rdf:resource="https://launchpad.net/ubuntu/+source/unzip"/>
                    <prov:used rdf:resource="'$downloadURL'"/>
                    <prov:generated rdf:resource="http://frb.270a.info/data/'$DataSetCode''$DataTypePath'.xml"/>
                    <rdfs:label xml:lang="en">Retrieved '$DataSetCode' '$DataTypeLabel'</rdfs:label>
                    <rdfs:comment xml:lang="en">'$DataTypeLabel' of dataset '$DataSetCode' retrieved from source and saved to local filesystem.</rdfs:comment>
                </rdf:Description>' >> "$data""$agency".prov.retrieval.rdf ;
            done
        (( counter++ ));
    done < frb.temp

echo -e "\n</rdf:RDF>" >> "$data""$agency".prov.retrieval.rdf ;

mv frb.temp /tmp/

scripts=$(pwd)

cd "$data"
for i in *.zip ; do unzip -o "$i" ; done

cd "$scripts"



