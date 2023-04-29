## Coin Tracker Project

# High Level Explanation
This project implements a simple "Hello World" website. Under the covers it is a simple terraform script which builds different infrastructure components to serve the data. I am using a static web page and serving that through an S3 acting as a static website. Cloudfront servers this page using Object Access Identity and accessing the static website URL. Route53 connects the URL to cloudfront endpoint and cloudfront origin connects to s3 endpoint

# Implementation Details
The main logic of implementation is in the main.tf file. S3 bucket, Cloudfront, ACM certificate, Route53 changes are all created using this file. 

# Deployment
Run the deploy.sh script to deploy the infrastructure. Navigate to the URL(cointracker.srivijayapuri.cloud/index.html) on webpage to see the output.

# Further improvements I could not not work on
1. I think I should have broken down main.tf into different files based on services like cloudfront.tf, s3.tf, route53.tf, acm.tf
2. Implement a staging directory and have individual main.tf inside staging directory(like dev, prod). Developers can log into individual staging directory and deploy the code to that stage
3. Have a drop.sh script to drop and cleanup the infrastructure
4. Further enhance the infrastructure implementation by changing the architecture from using s3 static website to something which is more handled by code like API gateway and lambda. Route53 -> Cloudfront - API Gateway -> Lambda
5. Implement a jenkins file which would call the deploy.sh script to automate deployment of this code so that an implementation engineer can deploy this code or it can be scheduled to deploy/update automatically based on a schedule
6. I could go on with other ideas but these are top 5 things I would have implemented next if I had the time. 
