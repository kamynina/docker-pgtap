# PostgreSQL tests (pgtap) runner
[![Build Status](https://travis-ci.org/kamynina/docker-pgtap.svg?branch=master)](https://travis-ci.org/kamynina/docker-pgtap)

Image for run pg-tests based on pgTap framework. For run tests use pg_prove.

## Script style

## xUnit test style

```
docker run --rm -v /home/gabby/pg/example/:/t \  
  kamynina/pgtap:0.97 \ 
  -h 172.17.0.2 \
  -u postgres \
  -d postgres \
  -i /t/tests/api/_init.sql
```