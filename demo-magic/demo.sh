#!/bin/bash

########################
# include the magic
#
# p    - print only, do not execute
# pe   - print and execute when enter is presse
# pei  - print and execute immediately
# wait - wait until enter is pressed
# cmd  - interactive mode
#      - run commands behind the scenes, can be useful for hiding sensitive information
#
########################

# set path to demo magic shell script
DEMO_MAGIC=

# source demo magic shell script
. $DEMO_MAGIC

# hide the evidence
clear

PUBLIC_CLUSTER_USER=
PUBLIC_CLUSTER_PASSWORD=
PUBLIC_CLUSTER_API=
PUBLIC_CLUSTER_PROJECT=

PRIVATE_CLUSTER_USER=
PRIVATE_CLUSTER_PASSWORD=
PRIVATE_CLUSTER_API=
PRIVATE_CLUSTER_PROJECT=

# print title
p "Starting Skupper MySQL Demo"
yes '' | head -n3

# login to public cluster
pe 'oc login -u $PUBLIC_CLUSTER_USER -p $PUBLIC_CLUSTER_PASSWORD --server $PUBLIC_CLUSTER_API'
yes '' | head -n3
pe 'oc new-project $PUBLIC_CLUSTER_PROJECT'
yes '' | head -n3
pe 'oc config set-context $(oc config current-context) --namespace=$PUBLIC_CLUSTER_PROJECT'
yes '' | head -n3
pe 'oc config rename-context $(oc config current-context) $PUBLIC_CLUSTER_PROJECT'
yes '' | head -n3

# relax pod security to supress warnings in public cluster
p 'set some labels on the namespace'
oc label ns $PUBLIC_CLUSTER_PROJECT security.openshift.io/scc.podSecurityLabelSync=false
oc label --overwrite ns $PUBLIC_CLUSTER_PROJECT \
        pod-security.kubernetes.io/enforce=privileged \
        pod-security.kubernetes.io/warn=baseline \
        pod-security.kubernetes.io/audit=baseline
yes '' | head -n3


# login to private cluster
pe 'oc login -u $PRIVATE_CLUSTER_USER -p $PRIVATE_CLUSTER_PASSWORD --server $PRIVATE_CLUSTER_API'
yes '' | head -n3
pe 'oc new-project $PRIVATE_CLUSTER_PROJECT'
yes '' | head -n3
pe 'oc config set-context $(oc config current-context) --namespace=$PRIVATE_CLUSTER_PROJECT'
yes '' | head -n3
pe 'oc config rename-context $(oc config current-context) $PRIVATE_CLUSTER_PROJECT'
yes '' | head -n3

# relax pod security to supress warnings in private cluster
p 'set some labels on the namespace'
oc label ns $PRIVATE_CLUSTER_PROJECT security.openshift.io/scc.podSecurityLabelSync=false
oc label --overwrite ns $PRIVATE_CLUSTER_PROJECT \
        pod-security.kubernetes.io/enforce=privileged \
        pod-security.kubernetes.io/warn=baseline \
        pod-security.kubernetes.io/audit=baseline
yes '' | head -n3

# initialize skupper
p "The 'skupper init' command installs the Skupper router and service controller in the current project"
yes '' | head -n3

pe 'oc config use-context $PUBLIC_CLUSTER_PROJECT'
pe "skupper init --enable-console --enable-flow-collector"
yes '' | head -n3

pe 'oc config use-context $PRIVATE_CLUSTER_PROJECT'
pe "skupper init "
yes '' | head -n3

# check skupper status for public cluster
pe 'oc config use-context $PUBLIC_CLUSTER_PROJECT'
pe "skupper status"
yes '' | head -n3

# check skupper status for private cluster
pe 'oc config use-context $PRIVATE_CLUSTER_PROJECT'
pe "skupper status"
yes '' | head -n3

# create token and link clusters
p "Creating a link needs two skupper commands: 'skupper token create' and 'skupper link create'"
pe 'oc config use-context $PUBLIC_CLUSTER_PROJECT'
yes '' | head -n3
p "The 'skupper token create' command generates a secret token with the permission to create a link"
pe 'skupper token create ./secret.token'
yes '' | head -n3
p "Token should be kept secret, but let's look at for this demo only."
pe 'cat ./secret.token'
yes '' | head -n3

p "From a remote cluster, the 'skupper link create' command uses the token to create a link to the cluster that generated it"
pe 'oc config use-context $PRIVATE_CLUSTER_PROJECT'
yes '' | head -n3
pe 'skupper link create ./secret.token'
yes '' | head -n3


# install database in the private cluster
p "Use the 'oc apply' in the private cluster to install the MySQL database server"
pe 'cat ../database/kubernetes.yaml'
yes '' | head -n3
pe 'oc config use-context $PRIVATE_CLUSTER_PROJECT'
yes '' | head -n3
pe "oc apply -f ../database/kubernetes.yaml"
yes '' | head -n3

# expose database via skupper
p "Use 'skupper expose' to expose the database server on the Skupper network"
pe "skupper expose deployment/database --port 3306"
yes '' | head -n3

p "Then, in the public cluster, use 'oc get service/database' to check that the database service appears"
pe 'oc config use-context $PUBLIC_CLUSTER_PROJECT'
yes '' | head -n3
pe "oc get service/database"
yes '' | head -n3

# run the database client in the public cluster
p "Use 'oc run' to run the mysql client in a pod"
pe "oc run client --attach --rm --image docker.io/library/mysql --restart Never --env MYSQL_PWD=secret -- mysql -h database -u root -e 'select version();'"
yes '' | head -n3
pe "oc run client --attach --rm --image docker.io/library/mysql --restart Never --env MYSQL_PWD=secret -- mysql -h database -u root -e 'use bookmanagement; select title,author, language from books\G'"
yes '' | head -n3

# access skupper web console
p "Skupper includes a web console you can use to view the virtual application network"
pe "skupper status"
yes '' | head -n3
pe "oc get secret/skupper-console-users -o jsonpath={.data.admin} | base64 -d"
yes '' | head -n3

# end demo
p "Completing Skupper MySQL Demo"

wait

rm ./secret.token

oc config use-context $PRIVATE_CLUSTER_PROJECT
skupper delete
oc delete project $PRIVATE_CLUSTER_PROJECT
oc config delete-context $PRIVATE_CLUSTER_PROJECT

oc config use-context $PUBLIC_CLUSTER_PROJECT 
skupper delete
oc delete project $PUBLIC_CLUSTER_PROJECT
oc config delete-context $PUBLIC_CLUSTER_PROJECT

