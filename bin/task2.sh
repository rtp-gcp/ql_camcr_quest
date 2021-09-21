#!/bin/bash
echo "Create a Kubernetes Service Cluster"
echo "Setting Compute/zone to US East"
gcloud config set compute/zone us-east1-b
echo "Creating Kube Cluster"
gcloud container clusters create nucleus-cluster --num-nodes 1 
echo "Getting Cluster Credentials"
gcloud container clusters get-credentials nucleus-cluster
echo "Deploy Hello Server App"
kubectl create deployment hello-server  --image=gcr.io/google-samples/hello-app:2.0
echo "Exposing App"
kubectl expose deployment hello-server --type=LoadBalancer --port 8080
