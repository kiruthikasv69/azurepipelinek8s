AKS CI/CD with Terraform and Azure Pipeline (Dev and Prod Environments)

This project demonstrates a CI/CD pipeline using Terraform and Azure Pipelines to deploy an application into Azure Kubernetes Service (AKS). It includes separate environments for development and production.

Project Structure:

envs/dev/: Terraform code for Dev AKS cluster, ACR, and resources.

envs/prod/: Terraform code for Prod AKS cluster, ACR, and resources.

app/: Sample application code (Node.js or Python).

k8s/: Kubernetes deployment and service YAML files.

azure-pipelines.yml: Azure DevOps pipeline definition.

CI/CD Flow:

Dev Stage:

Run terraform apply in envs/dev/ to provision AKS and ACR.

Azure Pipeline builds Docker image, pushes to Dev ACR.

Application deployed to Dev AKS using Kubernetes manifests.

Prod Stage:

After Dev validation, run terraform apply in envs/prod/.

Azure Pipeline deploys the same Docker image to Prod AKS.

Manual approval is required before Prod deployment.

Key Points:

Terraform manages infrastructure for both environments.

Dev and Prod have separate AKS clusters and ACRs.

Manual gate is enabled before deploying to production.