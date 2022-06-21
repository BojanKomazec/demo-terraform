// execute terraform apply (or after it, terraform show) in order to see output values
outtput "ami_id" {
    description = "ID of the filtered AMI"
    value       = data.aws_ami.amzn2_ami.id
}