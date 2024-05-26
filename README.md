Terraform demo scripts.

# Simple Terraform workflow

Format .tf files:
```
terraform fmt
```
Validate .tf files:
```
terraform validate
```
Initialize the working directory containing the root .tf file:
```
terraform init
```
See and review the execution plan:
```
terraform plan
```
Apply changes:
```
terraform apply
```
See the changes made:
```
terraform show
```
Destroy created resources:
```
terraform destroy
```

# terraform plan

To print the output with no colors (escape sequences which can be parsed by terminal but not e.g. GitHub web parser):
```
terraform plan -no-color
```

To get the plan in pure JSON, save it first (as a binary file) and then use `show` command:
```
terraform plan -out tfplan
terraform show -json tfplan
```



