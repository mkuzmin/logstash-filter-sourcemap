#!/bin/sh
docker-compose -f docker-gem.yml up
docker-compose build logstash
docker-compose up
