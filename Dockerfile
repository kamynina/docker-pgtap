FROM postgres:9.6.3

RUN apt-get update && apt-get install -y --no-install-recommends ca-certificates git build-essential curl postgresql-server-dev-$PG_MAJOR

WORKDIR /tmp
RUN git clone --branch v0.97.0 https://github.com/theory/pgtap.git && \
  cd pgtap && \
  make && \
  make install

# install pg_prove
RUN curl -LO http://xrl.us/cpanm \
    && chmod +x cpanm \
    && ./cpanm TAP::Parser::SourceHandler::pgTAP

COPY ./run-tests.sh /run-tests.sh
RUN chmod +x /run-tests.sh

WORKDIR /

CMD ["/run-tests.sh"]
ENTRYPOINT ["/run-tests.sh"]
