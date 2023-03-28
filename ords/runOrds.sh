#!/bin/bash
# 
# The Idea comes from the Oracle's git repository for 
# installing and starting the ORDS. But the oracle script don't
# run with ORDS 22.1 and above, so i create a new config script
#
# sascha@methusalem.net
#   runOrds.sh config for installation ORDS 22.1 and above

function checkDatabase() {
  echo "Check database connection"
  CONNSTR="${SYSDBA_USER}/${SYSDBA_PASSWORD}@${ORACLE_HOST}:${ORACLE_PORT}/${ORACLE_SERVICE}"
  for i in {1..10}
  do
    echo "select 1 from dual;" | sqlplus -s ${CONNSTR} as sysdba > /dev/null 2>&1
    RC=$?

    echo "try ... ${i}, rc = ${RC}"

    if [ "${RC}" -eq 0 ]
    then
      echo "database status is open"
      break
    fi

    sleep 10
  done
}

function setupOrds() {

  # Check whether the Oracle DB password has been specified
  if [ "${ORACLE_PASSWORD}" == "" ]; then
    echo "Error: No ORACLE_PWD specified!"
    echo "Please specify Oracle DB password using the ORACLE_PWD environment variable."
    exit 1;
  fi;

  # Defaults
  ORACLE_SERVICE=${ORACLE_SERVICE:-"ORCLPDB1"}
  ORACLE_HOST=${ORACLE_HOST:-"localhost"}
  ORACLE_PORT=${ORACLE_PORT:-"1521"}
  ORDS_PWD=${ORDS_PWD:-"oracle"}
  APEXI=${APEXI:-"${ORACLE_HOME}/apex/images"}
  
  ${ORDS_HOME}/bin/ords --config ${ORDS_CONFIG_DIR} install \
       --admin-user ${SYSDBA_USER} \
       --proxy-user \
       --db-hostname ${ORACLE_HOST} \
       --db-port ${ORACLE_PORT} \
       --db-servicename ${ORACLE_SERVICE} \
       --feature-sdw true \
       --password-stdin << EOF
${SYSDBA_PASSWORD}
${ORDS_PWD}
EOF

  if [ -d ${APEXI} ]; then
    ${ORDS_HOME}/bin/ords --config ${ORDS_CONFIG_DIR} config set standalone.static.path ${ORACLE_HOME}/apex/images;
  fi

  # set HTTPS as Default
  ${ORDS_HOME}/bin/ords --config ${ORDS_CONFIG_DIR} config set standalone.https.port 8443
}

############# MAIN ################
# check if database is up and open
checkDatabase;

# Check whether ords is already setup
if [ ! -e ${ORDS_CONFIG_DIR}/databases/default/pool.xml ]; then
   setupOrds;
fi;

${ORDS_HOME}/bin/ords --config ${ORDS_CONFIG_DIR} serve