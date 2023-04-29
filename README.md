## Coin Tracker Project

# High Level Explanation
This project implements a simple "Hello World" website. Under the covers it is a simple terraform script which builds different infrastructure components to serve the data. I am using a static web page and serving that through an S3 acting as a static website. Cloudfront servers this page using Object Access Identity and accessing the static website URL. Route53 connects the URL to cloudfront endpoint and cloudfront origin connects to s3 endpoint

# Implementation Details
The main logic of implementation is in the main.tf file. S3 bucket, Cloudfront, ACM certificate, Route53 changes are all created using this file. 

# Deployment
Run the deploy.sh script to deploy the infrastructure. Navigate to the URL(cointracker.srivijayapuri.cloud/index.html) on webpage to see the output.
