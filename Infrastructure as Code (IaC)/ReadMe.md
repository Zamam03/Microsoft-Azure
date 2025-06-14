# Azure IaC Templates
This folder contains matching Terraform (.tf) and ARM (.json) templates for Azure deployments. Each application has both versions in the same directory.

## Applications
1. **Voting App** - Files: `voting_app.tf` (Terraform) | `voting_app.json` (ARM) - Components: Python frontend, Redis, .NET worker, PostgreSQL, Node.js results
2. **Donation App** - Files: `donation_app.tf` (Terraform) | `donation_app.json` (ARM) - Components: [Add components]

## Deployment
**Terraform:** `terraform init && terraform apply`  
**ARM:** `az deployment group create --template-file voting_app.json --resource-group myRG`

## Structure
`/voting_app.tf` (Voting Terraform) | `/voting_app.json` (Voting ARM) | `/donation_app.tf` (Donation Terraform) | `/donation_app.json` (Donation ARM)

## Cleanup
**Terraform:** `terraform destroy`  
**ARM:** `az group delete -n myRG`

I will add new apps by creating matching .tf/.json pairs and updating this README.
