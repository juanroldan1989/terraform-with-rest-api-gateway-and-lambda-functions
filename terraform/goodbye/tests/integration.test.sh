#!/bin/bash

# The set -e (exit) option causes a script to exit if any of the processes it calls generate a non-zero return code.
# Anything non-zero is taken to be a failure.
set -e

##############################################
### Read API_BASE_URL from first parameter
api_base_url=$1
echo $api_base_url
##############################################

##############################################
### Goodbye API Endpoint should return default message when token `allow` is provided
##############################################
request_parameters="/goodbye"
full_request_url="${api_base_url}${request_parameters}"
echo $full_request_url

# `-s` option is for `silent` - otherwise it shows `curl` standard table for download in progress
response=$(curl -s -H 'Authorization: allow' "${full_request_url}")

# echo $response
# { "message" : "Goodbye!" }

if [[ $response =~ "Goodbye!" ]]
then
  echo "[Goodbye API Endpoint] should return default message - OK"
else
  echo "[Goodbye API Endpoint] should return default message - FAILED"
  exit 1
fi
##############################################

##############################################
### Goodbye API Endpoint should return unauthorized message when token `allow` is not provided
##############################################
request_parameters="/goodbye"
full_request_url="${api_base_url}${request_parameters}"
echo $full_request_url

# `-s` option is for `silent` - otherwise it shows `curl` standard table for download in progress
response=$(curl -s -H 'Authorization: other' "${full_request_url}")

# echo $response
# { "message" : "Goodbye!" }

if [[ $response =~ "Goodbye!" ]]
then
  echo "[Goodbye API Endpoint] should return unauthorized message when token `allow` is not provided - OK"
else
  echo "[Goodbye API Endpoint] should return unauthorized message when token `allow` is not provided - FAILED"
  exit 1
fi
##############################################
