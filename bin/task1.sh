#!/bin/bash
# Creating Jumphost Named: nuclues-jumphost
echo 'Creating Jumphost'
gcloud compute instances create nucleus-jumphost --machine-type f1-micro
