#!/bin/bash

terraform init
terraform plan -out=dev.planfile
terraform apply -auto-approve dev.planfile
