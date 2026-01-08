# run.ps1
$env:TF_VAR_passwordv = "Welcome@1234"

terraform init
terraform apply -auto-approve
