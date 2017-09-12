#!/usr/bin/env bash


USER=(
"org1:xxxxxxxxxx"
"org2:xxxxxxxxxx")

USER=admin
PASSWORD=ir8isypsg7dynjekdu5z

HOST="172.28.106.6:3000"
FILE_DIR=path/to/export

fetch_fields() {
    echo $(curl  "http://${USER}:${PASSWORD}@${HOST}/api/${1}" | jq -r "if type==\"array\" then .[] else . end| .${2}")
}

if [ ! -d "$FILE_DIR" ] ; then
    mkdir -p "$FILE_DIR"
fi

for row in "${ORGS[@]}" ; do
    ORG=${row%%:*}
    KEY=${row#*:}
    DIR="$FILE_DIR/$ORG"

    if [ ! -d "$DIR" ] ; then
    	mkdir -p "$DIR"
	  fi

	if [ ! -d "$DIR/dashboards" ] ; then
	    mkdir -p "$DIR/dashboards"
	fi

	if [ ! -d "$DIR/datasources" ] ; then
    	    mkdir -p "$DIR/datasources"
    	fi

    for dash in $(fetch_fields 'search?query=&' 'uri'); do
        DB=$(echo ${dash}|sed 's,db/,,g').json
        echo $DB
    	curl "http://${USER}:${PASSWORD}@${HOST}/api/dashboards/${dash}" | jq '.dashboard.id = null' | jq '.overwrite = true' > "$DIR/dashboards/$DB"
    done

	for id in $(fetch_fields $KEY 'datasources' 'id'); do
        DS=$(echo $(fetch_fields $KEY "datasources/${id}" 'name')|sed 's/ /-/g').json
        echo $DS
        curl "http://${USER}:${PASSWORD}@${HOST}/api/datasources/${id}" | jq '.id = null' | jq '.orgId = null' > "$DIR/datasources/$DS"
    done

done
