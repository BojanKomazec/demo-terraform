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
# terraform output

Default output is output to a file. To get human-oriented output use:
```
terraform output
```
If Heredoc is used to assign a value to the variable Terraform will include Heredoc markers (e.g. <<EOT and EOT) in its rendering of the value because the output from Terraform is intended to be similar to the configuration syntax, but the actual value saved in the state was the final value without those markers.

A way to get machine-oriented output (which does not contain Heredoc markers)
```
terraform output -json
```

Output variables from non-root modules are not shown (in planning phase).
We need to define output variable in the root module which will return the value of the output variable of the child modules.


