#!/bin/bash
# Setup
set -x
set -e
PROJECT_ID="urbanindo-data-platform"

# Load Listing Secondary Data
rm -rf masterAgent.tsv*
aws s3 cp s3://data.99iddev.net/rumah123-daily-sync/master_agent/masterAgent.schema.json masterAgent.schema.json
aws s3 cp $1 masterAgent.tsv

# Data Cleaning
sed -i 's/\\n//g' masterAgent.tsv

# Compress with GZip
gzip masterAgent.tsv

# Load to BigQuery
bq load --project_id=$PROJECT_ID \
    --replace --schema="masterAgent.schema.json" \
    --source_format=CSV --field_delimiter="\t" \
    --max_bad_records=10000 r123.MasterAgent \
    masterAgent.tsv.gz