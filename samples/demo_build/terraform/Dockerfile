FROM hashicorp/terraform:light

ADD gcp.tf /terraform/gcp/gcp.tf
ADD variables.tf /terraform/gcp/variables.tf
RUN terraform init /terraform/gcp

ENTRYPOINT ["/bin/terraform"]
CMD ["apply","-auto-approve","-state=/terraform/terraform_state/terraform.tfstate","/terraform/gcp/"]
