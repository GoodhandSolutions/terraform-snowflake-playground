init:
	terraform init

deploy: init
	terraform apply -auto-approve

destroy:
	terraform destroy -auto-approve

clean:
	rm -f terraform.tfstate terraform.tfstate.backup
