FROM docker.elastic.co/elasticsearch/elasticsearch:8.6.2

LABEL de.sandstein.dde="elasticsearch"

# Elasticsearch 8 runs as the elasticsearch user; switch back to root so derived
# images can run modify-user-ids, elasticsearch-as-user drops privileges at start.
USER root

COPY files/usr/local/bin/modify-user-ids /usr/local/bin
COPY files/usr/local/bin/modify-elasticsearch-entrypoint /usr/local/bin
COPY files/usr/local/bin/elasticsearch-as-user /usr/local/bin

ENTRYPOINT ["/bin/tini", "--", "/usr/local/bin/elasticsearch-as-user"]
CMD ["eswrapper"]
