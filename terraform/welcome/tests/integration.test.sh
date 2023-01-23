#!/bin/bash

# The set -e (exit) option causes a script to exit if any of the processes it calls generate a non-zero return code.
# Anything non-zero is taken to be a failure.
set -e

##############################################
### Read API_BASE_URL from first parameter
api_base_url=$1
echo $api_base_url

### Read API_KEY_FREE_PLAN from second parameter
api_key_free_plan=$2
echo $api_key_free_plan
##############################################

##############################################
### Welcome API Endpoint should return default message when API KEY is provided
##############################################
custom_url="/welcome"
full_request_url="${api_base_url}${custom_url}"
echo $full_request_url

# `-s` option is for `silent` - otherwise it shows `curl` standard table for download in progress
response=$(curl -s -H 'x-api-key: '$api_key_free_plan'' "${full_request_url}")

# echo $response
# { "message" : "Welcome :)" }

if [[ $response =~ "Welcome" ]]
then
  echo "[Welcome API Endpoint] should return default message when API KEY is provided - OK"
else
  echo "[Welcome API Endpoint] should return default message when API KEY is provided - FAILED"
  exit 1
fi
##############################################

##############################################
### Welcome API Endpoint should return forbidden message when API KEY is not provided
##############################################
custom_url="/welcome"
full_request_url="${api_base_url}${custom_url}"
echo $full_request_url

# `-s` option is for `silent` - otherwise it shows `curl` standard table for download in progress
response=$(curl -s "${full_request_url}")

# echo $response
# { "message" : "Forbidden" }

if [[ $response =~ "Forbidden" ]]
then
  echo "[Welcome API Endpoint] should return forbidden message when API KEY is not provided - OK"
else
  echo "[Welcome API Endpoint] should return forbidden message when API KEY is not provided - FAILED"
  exit 1
fi
##############################################
