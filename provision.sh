#!/bin/sh


create() {
  cf create-service aws-rds shared-psql mm-db 
  cf csk mm-db mm-db-key
}

#create

dbcreds=$(cf service-key mm-db mm-db-key | grep -v '^Getting')

echo $dbcreds | jq '.'

DB_HOST=$(echo $dbcreds | jq -r '.host')
DB_PORT_NUMBER=$(echo $dbcreds | jq -r '.port')
MM_USERNAME=$(echo $dbcreds | jq -r '.username')
MM_PASSWORD=$(echo $dbcreds | jq -r '.password')
MM_DBNAME=$(echo $dbcreds | jq -r '.db_name')

cf push --var DB_HOST=$DB_HOST \
    --var DB_PORT_NUMBER=$DB_PORT_NUMBER \
    --var MM_DBNAME=$MM_DBNAME \
    --var MM_USERNAME=$MM_USERNAME \
    --var MM_PASSWORD=$MM_PASSWORD


cf create-service cloud-gov-identity-provider oauth-client mm-oauth
cf bind-service mattermost-coe mm-oauth \
  -c '{"redirect_uri": ["https://mattermost-coe.app.cloud.gov/signup/gitlab/complete"]}'
cf restage mattermost-coe
cf csk mm-oauth mm-oauth-key \
  -c '{"redirect_uri": ["https://mattermost-coe.app.cloud.gov/signup/gitlab/complete"]}'
cf service-key mm-oauth mm-oauth-key
 
