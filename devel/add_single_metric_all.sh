#!/bin/bash
if [ -z "${PG_PASS}" ]
then
  echo "You need to set PG_PASS environment variable to run this script"
  exit 1
fi

function finish {
    sync_unlock.sh
}
if [ -z "$TRAP" ]
then
  sync_lock.sh || exit -1
  trap finish EXIT
  export TRAP=1
fi

if [ -z "$ONLY" ]
then
  host=`hostname`
  if [ $host = "cncftest.io" ]
  then
    all=`cat ./devel/all_test_projects.txt`
  else
    all=`cat ./devel/all_prod_projects.txt`
  fi
else
  all=$ONLY
fi
for proj in $all
do
  db=$proj
  if [ "$db" = "kubernetes" ]
  then
    db="gha"
  elif [ "$db" = "all" ]
  then
    db="allprj"
  fi
  GHA2DB_PROJECT=$proj PG_DB=$db ./devel/add_single_metric.sh || exit 2
done

echo 'OK'
