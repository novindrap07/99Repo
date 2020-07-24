#!/bin/bash

set -ex

PROJECT_ID="urbanindo-data-platform"
DATASET="r123"

sudo yum -y install jq

function load_to_bq() {
    TABLE=$1

    rm -rf ${TABLE}.tsv*
    bq show --format=prettyjson ${PROJECT_ID}:${DATASET}.${TABLE} | jq '.schema.fields' > ${TABLE}.schema.json
    aws s3 cp $2 ${TABLE}.tsv
    sed -i 's/\\n//g' ${TABLE}.tsv
    gzip ${TABLE}.tsv
    bq load --project_id=$PROJECT_ID \
        --replace --schema="${TABLE}.schema.json" \
        --source_format=CSV --field_delimiter="\t" \
        ${DATASET}.${TABLE} \
        ${TABLE}.tsv.gz
}

# Load Primary Listing
load_to_bq District $1