FROM logstash:2.2
MAINTAINER Michael Kuzmin <mkuzmin@gmail.com>
RUN plugin install logstash-filter-prune
COPY *.gem /tmp/
RUN ls /tmp/*.gem | xargs plugin install
