env:=local

local_setup:
	./setup/local_config.sh
local_apply: local_setup init plan_apply apply
local_destroy: local_setup init plan_destroy destroy

remote_setup: format init validate

init:
	terraform init
plan_apply:
	terraform plan -var-file="$(env).tfvars" -out=terraform.tfplan
plan_destroy:
	terraform plan -var-file="$(env).tfvars" -out=terraform.tfplan -destroy
apply:
	terraform apply -auto-approve terraform.tfplan
destroy:
	terraform apply -auto-approve -destroy -var-file="$(env).tfvars"
format:
	terraform fmt -check
validate:
	terraform validate -no-color


setup_helm:
	kubectl create -f ./setup/rbac-config.yaml
	helm init --service-account tiller

setup_kubeflow:
	./setup/install_kubeflow.sh