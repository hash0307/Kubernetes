#!/bin/sh

#Update kubernetes namespace where the pods are deployed
kubns='kubectl -n <namespace>'
#Ex. kubns='kubectl -n payment_eu_1'

# Get current date/timestamp
dt=`date +"%m-%d-%y-%H%M%S"`


# Get list of all pods in the given namespace
podList=`$kubns get po | grep -v NAME | awk '{print $1}'`

for podname in ${podList}
do
	# Get initialized time for pod 
	initialized_time=$(date -d $($kubns get po "$podname" -o json | jq ".status.conditions[] | select (.type == \"Initialized\" and .status == \"True\") | .lastTransitionTime" | tr -d '"\n') +%s)
	
	#echo $initialized_time
	
	# Get ready time for pod 
	ready_time=$(date -d $($kubns get po "$podname" -o json | jq ".status.conditions[] | select (.type == \"Ready\" and .status == \"True\") | .lastTransitionTime" | tr -d '"\n') +%s)
	
	#echo $ready_time
	
	if test -n "$initialized_time" && test -n "$ready_time"; then
		startup_time=$(( $ready_time - $initialized_time ))
		echo "$podname, $startup_time" >> podstartuptime_$dt.csv
	else
		echo "$podname, NotFound" >> podstartuptime_$dt.csv
	fi
	
done
