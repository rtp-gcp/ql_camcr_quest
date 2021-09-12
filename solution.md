# ql_camcr_quest

## Task 1: Create a project jumphost instance

### Objective
 * Create an instance `nucleus-jumphost`
 * use `f1-micro` machine typoe
 * Use default image type


### Solution

#### create the VM
```

gcloud config set compute/zone us-central1-f

gcloud compute instances create nucleus-jumphost  \
             --machinte-type=f1-micro \
             firewall-rules create default-allow-http --direction=INGRESS \
             --priority=1000 --network=default --action=ALLOW \
             --rules=tcp:80 --source-ranges=0.0.0.0/0 \
             --target-tags=http-server \
             --zone=us-central1-f

vs

gcloud compute --project=a-test-project-320414  \
 firewall-rules create default-allow-http \
 --direction=INGRESS --priority=1000 --network=default \
 --action=ALLOW --rules=tcp:80 --source-ranges=0.0.0.0/0  \
 --target-tags=http-server

```

#### Install nginx

```
apt-get update
apt-get install nginx -y
gcloud compute instances list
```

verify the external IP has a webpage which shows "Welcome to nginx!"


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
kubectl create deployment hello-app \
--image=gcr.io/google-samples/hello-app:2.0

kubectl expose deployment hello-app \
--type=LoadBalancer --port 8080

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

gcloud compute instances create www1 \
  --image-family debian-9 \
  --image-project debian-cloud \
  --zone us-central1-a \
  --tags network-lb-tag \
  --metadata startup-script="#! /bin/bash
    sudo apt-get update
    sudo apt-get install apache2 -y
    sudo service apache2 restart
    echo '<!doctype html><html><body><h1>www1</h1></body></html>' | tee /var/www/html/index.html"
