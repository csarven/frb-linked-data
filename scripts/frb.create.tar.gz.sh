#!/bin/bash

. ./frb.config.sh

cd "$data"
tar -cvzf meta.tar.gz *struct.rdf frb.*rdf

tar -cvzf data.tar.gz *.rdf --exclude='*struct*' --exclude='frb.*'

