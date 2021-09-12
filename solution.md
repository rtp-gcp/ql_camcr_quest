# ql_camcr_quest

## Task 1: Create a project jumphost instance

### Objective
 * Create an instance `nucleus-jumphost`
 * use `f1-micro` machine typoe
 * Use default image type


### Solution

#### create the VM
```

gcloud config set compute/zone us-east1-b

gcloud compute instances create nucleus-jumphost  \
             --machine-type=f1-micro \
             --zone=us-east1-b

gcloud compute --project=qwiklabs-gcp-04-8e8061eb9cae \
             firewall-rules create default-allow-http --direction=INGRESS \
             --priority=1000 --network=default --action=ALLOW \
             --rules=tcp:80 --source-ranges=0.0.0.0/0 \
             --target-tags=http-server 

vs

gcloud compute --project=a-test-project-320414  \
 firewall-rules create default-allow-http \
 --direction=INGRESS --priority=1000 --network=default \
 --action=ALLOW --rules=tcp:80 --source-ranges=0.0.0.0/0  \
 --target-tags=http-server



## Task 2: Create a Kubernetes service cluster

### Objective
 * Create a cluster in us-east1-b zone 
 * Use docker container hello-app `gcr.io/google-samples/hello-app:2.0
 * expose the app on port 8080


#### create  cluster

```
gcloud config set compute/zone us-east1-b
gcloud container clusters create nucleus-cube
gcloud container clusters get-credentials nucleus-cube
```

#### deploy  cluster
```
kubectl create deployment hello-app  --image=gcr.io/google-samples/hello-app:2.0

kubectl expose deployment hello-app --type=LoadBalancer --port 80 --target-port 8080

vs

kubectl expose deployment hello-app --type=LoadBalancer --port 8080
```

Test the cluster with

* `kubectl get service`
* get external ip
* open web browser to http://externalip:8080



## Task 3: Set up an HTTP load balancer

### Objective

Serve site via nginx web servers
Ensure site is fault-tolerant

Create an HTTP load balancer of two nginx web servers

given:

```
cat << EOF > startup.sh
#! /bin/bash
apt-get update
apt-get install -y nginx
service nginx start
sed -i -- 's/nginx/Google Cloud Platform - '"\$HOSTNAME"'/' /var/www/html/index.nginx-debian.html
EOF
```








* Create an instance template.
* Create a target pool.
* Create a managed instance group.
* Create a firewall rule to allow traffic (80/tcp).
* Create a health check.
* Create a backend service, and attach the managed instance group.
* Create a URL map, and target the HTTP proxy to route requests to your URL map.
* Create a forwarding rule.


### Solution


```
Create the startup.sh as given
chmod +x startup.sh




#new          --machine-type g1-small \



gcloud compute instance-templates create web-server-template \
   --region=us-east1 \
   --network=nucleus-vpc \
   --machine-type g1-small \
   --metadata-from-file startup-script=startup.sh
#missing  --tags=allow-health-check \
#missing   --image-family=debian-9 \
#missing   --image-project=debian-cloud \


gcloud compute instance-groups managed create web-server-group \
          --base-instance-name web-server \
   --template=web-server-template --size=2 --region=us-east1

new
gcloud compute firewall-rules create web-server-firewall \
          --allow tcp:80 \
          --network nucleus-vpc

#gcloud compute firewall-rules create fw-allow-health-check \
#    --network=default \
#    --action=allow \
#    --direction=ingress \
#    --source-ranges=130.211.0.0/22,35.191.0.0/16 \
#    --target-tags=allow-health-check \
#    --rules=tcp:80

#gcloud compute addresses create lb-ipv4-1 \
#    --ip-version=IPV4 \
#    --global

gcloud compute http-health-checks create http-basic-check



gcloud compute backend-services create web-server-backend \
    --protocol=HTTP \
    --http-health-checks=http-basic-check \
    --global


gcloud compute instance-groups managed \
          set-named-ports web-server-group \
          --named-ports http:80 \
          --region us-east1



gcloud compute backend-services add-backend web-backend-service \
    --instance-group=web-server-group \
    --instance-group-region=us-east1 \
    --global





gcloud compute url-maps create web-map-http  --default-service web-server-backend



gcloud compute target-http-proxies create http-lb-proxy  --url-map web-map-http



gcloud compute forwarding-rules create http-content-rule \
    --global \
    --target-http-proxy=http-lb-proxy \
    --ports=80

gcloud compute forwarding-rules list
```























