#!/bin/sh -e

until $(curl --output /dev/null --silent --fail http://kibana:5601/status); do
  echo 'Waiting for Kibana...'
  sleep 5
done

curl -sS -X POST 'http://elasticsearch:9200/.kibana/index-pattern/*?op_type=create' -d @/conf/index-pattern.json
echo
curl -sS -X POST 'http://elasticsearch:9200/.kibana/config/4.4.1/_update' -d @/conf/config.json
echo
