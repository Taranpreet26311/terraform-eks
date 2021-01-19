# terraform-eks

terraform project to deploy a flask and redis app on EKS

Please make sure you have required permission in AWS such as EKS,IAM,EC2, etc. Make changes to the variables.tf files as per your requirements and run the script

`terraform init`

`terraform apply`

To access flask app use port-forwarding

`kubectl port-forward flask1-xxxx-xxxxx 1111:5000'

