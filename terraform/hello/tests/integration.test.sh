#!/bin/bash

# The set -e (exit) option causes a script to exit if any of the processes it calls generate a non-zero return code.
# Anything non-zero is taken to be a failure.
set -e

# TODO: adjust this call with API_KEY

##############################################
### Read API_BASE_URL from first parameter
api_base_url=$1
echo $api_base_url
##############################################

##############################################
### Hello API Endpoint should return default message when no parameters are provided
##############################################
request_parameters="/hello"
full_request_url="${api_base_url}${request_parameters}"
echo $full_request_url

# `-s` option is for `silent` - otherwise it shows `curl` standard table for download in progress
response=$(curl -s "${full_request_url}")

# echo $response
# { "message" : "Hello, world!" }

if [[ $response =~ "Hello, world!" ]]
then
  echo "[Hello API Endpoint] should return default message when no parameters are provided - OK"
else
  echo "[Hello API Endpoint] should return default message when no parameters are provided - FAILED"
  exit 1
fi
##############################################

##############################################
### Hello API Endpoint should return custom message when NAME parameter is provided
##############################################
request_parameters="/hello?Name=John"
full_request_url="${api_base_url}${request_parameters}"
echo $full_request_url

response=$(curl -s "${full_request_url}")

if [[ $response =~ "John" ]]
then
  echo "[Hello API Endpoint] should return custom message when NAME parameter is provided - OK"
else
  echo "[Hello API Endpoint] should return custom message when NAME parameter is provided - FAILED"
  exit 1
fi
##############################################
