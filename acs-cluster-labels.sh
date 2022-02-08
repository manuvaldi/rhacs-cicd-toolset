#!/bin/bash
# Usage, ./policy-update.sh policy.json

action="$1"
option1="$2"
option2="$3"

function help(){
    echo >&2 "usage: acs-cluster-label.sh <action> <option1> <option2>"
    echo >&2 "       acs-cluster-label.sh list"
    echo >&2 "       acs-cluster-label.sh showlabels"
    echo >&2 "       acs-cluster-label.sh showlabels <clusterid>"
    echo >&2 "       acs-cluster-label.sh setlabel <clusterid> <label>"
    echo >&2 "         example:  acs-cluster-label.sh setlabel 6e6b4fd2-aaaa-bbbb-cccc-e311da7caeaf environment=dev"
    echo >&2 "       acs-cluster-label.sh unsetlabel <clusterid> <label or key>"
    echo >&2 "         example1:  acs-cluster-label.sh unsetlabel 6e6b4fd2-aaaa-bbbb-cccc-e311da7caeaf environment=dev"
    echo >&2 "         example2:  acs-cluster-label.sh unsetlabel 6e6b4fd2-aaaa-bbbb-cccc-e311da7caeaf environment"
}

function curl_get_clusters() {
  curl -sk -H "Authorization: Bearer ${ROX_API_TOKEN}" "https://${ROX_API_ENDPOINT}/v1/clusters"
}

function curl_get_cluster() {
  curl -sk -H "Authorization: Bearer ${ROX_API_TOKEN}" "https://${ROX_API_ENDPOINT}/v1/clusters/$1"
}

function curl_get_policy() {
  curl -sk -H "Authorization: Bearer ${ROX_API_TOKEN}" "https://${ROX_API_ENDPOINT}/v1/policies?query=Policy%3A$1"
}

function curl_get_policy_details() {
    curl -sk -H "Authorization: Bearer ${ROX_API_TOKEN}" "https://${ROX_API_ENDPOINT}/v1/policies/$1"
}

function curl_post_policy() {
  curl -sk -XPOST -H "Authorization: Bearer ${ROX_API_TOKEN}" "https://${ROX_API_ENDPOINT}/v1/policies" --data "$(input_data)"
}

function curl_put_policy() {
  curl -sk -XPUT -H "Authorization: Bearer ${ROX_API_TOKEN}" "https://${ROX_API_ENDPOINT}/v1/policies/$1" --data "$(input_data)"
}

function curl_put_cluster() {
  _clusterid="$1"
  _clusterjson="$2"
  #echo "...."
  #echo curl -sk -XPUT -H "Authorization: Bearer ${ROX_API_TOKEN}" "https://${ROX_API_ENDPOINT}/v1/clusters/$_clusterid" --data "$_clusterjson"
  curl -sk -XPUT -H "Authorization: Bearer ${ROX_API_TOKEN}" "https://${ROX_API_ENDPOINT}/v1/clusters/$_clusterid" --data "$_clusterjson" 1>/dev/null
  #echo "...."

}

function clusters_list() {
  echo "NAME|ID"
  curl_get_clusters | jq -r '.clusters[] | [.name, .id] | join("|")'
}

function clusters_get_labels() {
  echo "NAME|ID|LABELS"
  if [[ -z "$1" ]]; then
    curl_get_clusters | jq -r '.clusters[] | [.name, .id, ((.labels | to_entries | map("\(.key)=\(.value)")) | join(","))] | join("|")'
  else
    curl_get_clusters | jq -r '.clusters[] | select(.id=="'$1'") | [.name, .id, ((.labels | to_entries | map("\(.key)=\(.value)")) | join(","))] | join("|")'
  fi
}

function clusters_set_label() {
  _id="$1"
  _label="$2"
  _key=$(echo "$_label" | cut -d "=" -f1)
  _value=$(echo "$_label" | cut -d "=" -f2)
  _payload=$(curl_get_cluster "$_id" | jq -c '.cluster')
  _payload_modified=$(echo "$_payload" | jq '.labels += {'$_key': "'$_value'"}')
  curl_put_cluster "$_id" "$_payload_modified"
}

function clusters_unset_label() {
  _id="$1"
  _label="$2"
  _key=$(echo "$_label" | cut -d "=" -f1)
  _value=$(echo "$_label" | cut -d "=" -f2)
  _payload=$(curl_get_cluster "$_id" | jq -c '.cluster')
  _payload_modified=$(echo "$_payload" | jq 'del(.labels.'$_key')' )
  curl_put_cluster "$_id" "$_payload_modified"
}


function print_columns(){
  column -t -s '|'
}

if [[ -z "${ROX_API_ENDPOINT}" ]]; then
  echo >&2 "ROX_ENDPOINT must be set"
  exit 1
fi

if [[ -z "${ROX_API_TOKEN}" ]]; then
  echo >&2 "ROX_API_TOKEN must be set"
  exit 1
fi

if [[ -z "$1" ]]; then
  help
  exit 1
fi



case $1 in
  list)
    clusters_list  | print_columns
  ;;

  showlabels)
    if [[ -z "${option1}" ]]; then
      clusters_get_labels | print_columns
    else
      clusters_get_labels $option1 | print_columns
    fi
  ;;

  setlabel)
    if [[ -z "${option1}" || -z "${option2}" ]]; then
      help
      exit 1
    fi
    clusters_set_label $option1 $option2 && (clusters_get_labels $option1 | print_columns)
  ;;

  unsetlabel)
    clusters_unset_label $option1 $option2 && (clusters_get_labels $option1 | print_columns)
  ;;
  *)
    help
  ;;
esac

exit
