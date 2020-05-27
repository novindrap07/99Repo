#!/bin/bash
# Setup
set -x
set -e
PROJECT_ID="urbanindo-data-platform"

# Load Listing Secondary Data
rm -rf secondary_listing.tsv*
aws s3 cp s3://data.99iddev.net/rumah123-daily-sync/listing-secondary/listingSecondary.schema.json listingSecondary.schema.json
aws s3 cp $1 secondary_listing.tsv

# Data Cleaning
sed -i 's/\\n//g' secondary_listing.tsv

# Compress with GZip
gzip secondary_listing.tsv

# Load to BigQuery
bq load --project_id=$PROJECT_ID \
    --replace --schema="listingSecondary.schema.json" \
    --source_format=CSV --field_delimiter="\t" \
    --max_bad_records=10000 r123.SecondaryListing \
    secondary_listing.tsv.gz