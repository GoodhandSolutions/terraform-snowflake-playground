# Makefile to simplify the execution of basic terraform commands.

init:
	rm -rf .terraform/
	terraform init -backend=true -backend-config=backend.tfvars

validate:
	terraform validate -var-file=terraform.tfvars

plan:
	terraform plan -var-file=terraform.tfvars

apply:
	terraform apply -var-file=terraform.tfvars

destroy:
	terraform destroy -var-file=terraform.tfvars

format:
	terraform fmt -recursive -diff .
