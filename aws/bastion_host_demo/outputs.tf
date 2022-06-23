output bastion_host_ec2_ip {
    description = "Captures Bastion Host public IP so we can SSH to it from dev box"
    value = [ for inst in aws_instance.bastion-host-ec2-instance: inst.public_ip ]
}

output private_ec2_ip {
    description = "Capture Private Ec2 Host private IP so we can SSH to it from bastion host"
    value = [ for inst in aws_instance.private-ec2-instance: inst.private_ip ]
}
