echo "Starting..."
export WAIOPS_NAMESPACE=$(oc get po -A|grep aimanager-operator |awk '{print$1}')
export EVTMGR_NAMESPACE=$(oc get po -A|grep noi-operator |awk '{print$1}')

CLUSTER_ROUTE=$(oc get routes console -n openshift-console | tail -n 1 2>&1 ) 
CLUSTER_FQDN=$( echo $CLUSTER_ROUTE | awk '{print $2}')
CLUSTER_NAME=${CLUSTER_FQDN##*console.}


export EVTMGR_REST_USR=$(oc get secret evtmanager-topology-asm-credentials -n $EVTMGR_NAMESPACE -o=template --template={{.data.username}} | base64 --decode)
export EVTMGR_REST_PWD=$(oc get secret evtmanager-topology-asm-credentials -n $EVTMGR_NAMESPACE -o=template --template={{.data.password}} | base64 --decode)
export LOGIN="$EVTMGR_REST_USR:$EVTMGR_REST_PWD"

oc create route passthrough topology-merge -n $EVTMGR_NAMESPACE --insecure-policy="Redirect" --service=evtmanager-topology-merge --port=https-merge-api


echo "URL: https://topology-merge-$EVTMGR_NAMESPACE.$CLUSTER_NAME/1.0/merge/"
echo "LOGIN: $LOGIN"  




## MERGE CREATE
curl -X "POST" "https://topology-merge-$EVTMGR_NAMESPACE.$CLUSTER_NAME/1.0/merge/rules?ruleType=matchTokensRule" --insecure \
     -H 'X-TenantID: cfd95b7e-3bc7-4006-a4a8-a73a79c71255' \
     -H 'content-type: application/json' \
     -u $LOGIN \
     -d $'{
  "tokens": [
    "name"
  ],
  "entityTypes": [
    "deployment"
  ],
  "providers": [
    "*"
  ],
  "observers": [
    "*"
  ],
  "ruleType": "mergeRule",
  "name": "merge-name-type",
  "ruleStatus": "enabled"
}'



curl "https://topology-merge-$EVTMGR_NAMESPACE.$CLUSTER_NAME/1.0/merge/rules?ruleType=mergeRule&_include_count=false&_field=*" --insecure \
     -H 'X-TenantID: cfd95b7e-3bc7-4006-a4a8-a73a79c71255' \
     -u $LOGIN


