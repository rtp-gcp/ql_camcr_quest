#!/bin/bash

template="web-server-template"
mtype="g1-small"
tpool="nucleus-pool"
instance_grp="web-svr-grp"

echo "Task3-1: Creating Instance-Template for Web Servers"
gcloud compute instance-templates create $template \
          --metadata-from-file startup-script=startup.sh \
          --machine-type $mtype 

echo "Task3-2: Creating a target pool"
gcloud compute target-pools create $tpool

echo "Task3-3: Creating a Instance Group"
gcloud compute instance-groups managed create $instance_grp \
          --base-instance-name nucleus-svr \
          --size 2 \
          --template $template \
	  --target-pool $tpool

echo "Task3-4a: Create a Firewall Rule for WWW"
gcloud compute firewall-rules create www-firewall --allow tcp:80 

echo "Task3-4b: Create forwarding Rule for Load Balancer"
gcloud compute forwarding-rules create www-lb \
	--region us-east1 \
	--ports=80 \
	--target-pool $tpool

echo "Task3-5a: Creating Healh Check"
gcloud compute http-health-checks create http-basic-check

echo "Task3-5b: Add instance Group check"
gcloud compute instance-groups managed set-named-ports $instance_grp \
	--named-ports http:80

echo "Task3-6a: Creating backend service"
gcloud compute backend-services create web-backend \
	--protocol HTTP \
	--http-health-checks http-basic-check \
	--global

echo "Task3-6b: adding instance group to backend service"
gcloud compute backend-services add-backend web-backend \
        --instance-group $instance_grp \
        --instance-group-zone us-east1-b \
        --global

echo "Task3-7a: Creating URL-map"
gcloud compute url-maps create web-map-http \
        --default-service web-backend

echo "Task3-7b: Creating HTTP proxy"
gcloud compute target-http-proxies create http-lb-proxy \
	--url-map web-map-http

echo "Task3-8: Creating Firewall Rule"
gcloud compute forwarding-rules create http-content-rule \
	--global \
	--target-http-proxy http-lb-proxy \
	--ports 80

