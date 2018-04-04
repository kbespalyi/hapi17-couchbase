FROM bentonam/couchbase-docker:enterprise-5.1.0

MAINTAINER couchbase-hos

ENV LCB_LOGLEVEL=5 \
    LCB_OPTIONS=detailed_errcodes=1

HEALTHCHECK --interval=5s --timeout=3s CMD curl --fail http://$COUCHBASE_HOST:$COUCHBASE_PORT/pools || exit 1

# COPY init.sh /
# RUN chmod +x /init.sh
# ENTRYPOINT ["/init.sh"]

# 8091: Couchbase Web console, REST/HTTP interface
# 8092: Views, queries, XDCR
# 8093: Query services (4.0+)
# 8094: Full-text Search (4.5+)
# 11207: Smart client library data node access (SSL)
# 11210: Smart client library/moxi data node access
# 11211: Legacy non-smart client library data node access
# 18091: Couchbase Web console, REST/HTTP interface (SSL)
# 18092: Views, query, XDCR (SSL)
# 18093: Query services (SSL) (4.0+)
# 18094: Full-text Search (SSL) (4.5+)
EXPOSE 8091 8092 8093 8094 11207 11208 11209 11210 11211 18091 18092 18093 18094

# VOLUME /opt/couchbase/var
