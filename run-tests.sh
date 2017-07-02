#!/bin/bash
DATABASE=
HOST=
PORT=5432
USER="postgres"
PASSWORD=
TESTS="/t/*.sql"
SCHEMA="test"
MODE="xUnit"
INSTALL_TEST_SCRIPT=
UNINSTALL_TEST_SCRIPT=

function usage() { echo "Usage: $0 -h host -d database -p port -u username -w password -t directory_with_tests" 1>&2; exit 1; }

while getopts d:h:p:u:w:b:n:t:i: OPTION
do
  case $OPTION in
    d)
      DATABASE=$OPTARG
      ;;
    h)
      HOST=$OPTARG
      ;;
    p)
      PORT=$OPTARG
      ;;
    u)
      USER=$OPTARG
      ;;
    w)
      PASSWORD=$OPTARG
      ;;
    t)
      TESTS=$OPTARG
      ;;
    i)
      INSTALL_TEST_SCRIPT=$OPTARG
      ;;
    *)
      usage
      ;;
  esac
done

if [[ -z $DATABASE ]] || [[ -z $HOST ]] || [[ -z $PORT ]] || [[ -z $USER ]] || [[ -z $TESTS ]]
then
  usage
  exit 1
fi

echo "Running tests: $TESTS"
# install pgtap
PGPASSWORD=$PASSWORD psql -h $HOST -p $PORT -d $DATABASE -U $USER -f /tmp/pgtap/sql/pgtap.sql > /dev/null 2>&1

rc=$?
# exit if pgtap failed to install
if [[ $rc != 0 ]] ; then
  echo "pgTap was not installed properly. Unable to run tests!"
  exit $rc
fi

if [ $MODE = "xUnit" ] ; then
  # install tests
  PGPASSWORD=$PASSWORD psql -h $HOST -p $PORT -d $DATABASE -U $USER -f $INSTALL_TEST_SCRIPT > /dev/null 2>&1
  rc=$?
  echo "Tests aren't installed"
  exit $rc

  # run the tests
  PGPASSWORD=$PASSWORD pg_prove -v -h $HOST -p $PORT -d $DATABASE -U $USER --schema test --match $TEST_PATTERN
else
  # run the tests
  PGPASSWORD=$PASSWORD pg_prove -h $HOST -p $PORT -d $DATABASE -U $USER $TESTS
fi

rc=$?
# uninstall pgtap
PGPASSWORD=$PASSWORD psql -h $HOST -p $PORT -d $DATABASE -U $USER -f /pgtap/sql/uninstall_pgtap.sql > /dev/null 2>&1

PGPASSWORD=$PASSWORD psql -h $HOST -p $PORT -d $DATABASE -U $USER -c "DROP SCHEMA IF EXISTS $SCHEMA CASCADE;" > /dev/null 2>&1
# exit with return code of the tests
exit $rc