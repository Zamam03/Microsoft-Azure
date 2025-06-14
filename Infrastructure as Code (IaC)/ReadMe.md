# Azure IaC Templates
This folder contains matching Terraform (.tf) and ARM (.json) templates for Azure deployments. Each application has both versions in the same directory.

## Applications
1. **Voting App** - Files: `voting_appinf.tf` (Terraform) | `voting_appinf.json` (ARM) - Components: Python frontend, Redis, .NET worker, PostgreSQL, Node.js results

## Deployment
**Terraform:** `terraform init && terraform apply`  
**ARM:** `az deployment group create --template-file voting_appinf.json --resource-group myRG`

## Structure
`/voting_appinf.tf` (Voting Terraform) | `/voting_appinf.json` (Voting ARM) 

## Cleanup
**Terraform:** `terraform destroy`  
**ARM:** `az group delete -n myRG`

I will add new apps by creating matching .tf/.json pairs and updating this README.
