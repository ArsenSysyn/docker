#!/bin/bash -e

export JAVA_OPTS='--add-opens java.base/java.net=ALL-UNNAMED --add-opens java.base/java.lang.invoke=ALL-UNNAMED'

if [ ! -d /var/gerrit/git/All-Projects.git ] || [ "$1" == "init" ]
then
  echo "Initializing Gerrit site ..."
  java $JAVA_OPTS -jar /var/gerrit/bin/gerrit.war init --batch --dev -d /var/gerrit
  java $JAVA_OPTS -jar /var/gerrit/bin/gerrit.war reindex -d /var/gerrit
  git config -f /var/gerrit/etc/gerrit.config --add auth.type "DEVELOPMENT_BECOME_ANY_ACCOUNT"
fi

git config -f /var/gerrit/etc/gerrit.config gerrit.canonicalWebUrl "$CANONICAL_WEB_URL"
if [ "$1" != "init" ]
then
  echo "Running Gerrit ..."
  exec /var/gerrit/bin/gerrit.sh run
fi
