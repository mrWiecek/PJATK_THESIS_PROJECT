env:=local

project_setup: project_install project_load_data
project_load_data:
	./src/load_data.sh
project_install:
	poetry install
	dvc init
	dvc config core.autostage true

pipeline_run: pipeline_prepare
pipeline_prepare:
	python ./src/prepare.py

infra_local_apply: local_setup init plan_apply apply
infra_local_setup:
	./local_config.sh
infra_local_destroy: local_setup init plan_destroy destroy
infra_remote_setup: format init validate
infra_init:
	terraform init
infra_plan_apply:
	terraform plan -var-file="$(env).tfvars" -out=terraform.tfplan
infra_plan_destroy:
	terraform plan -var-file="$(env).tfvars" -out=terraform.tfplan -destroy
infra_apply:
	terraform apply -auto-approve terraform.tfplan
infra_destroy:
	terraform apply -auto-approve -destroy -var-file="$(env).tfvars"
infra_format:
	terraform fmt -check
infra_validate:
	terraform validate -no-color
