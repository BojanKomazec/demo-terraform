output "subnet_ids" {
  // │ This object does not have an attribute named "id".
  // value = resource.aws_subnet.this[*].id
  value = [ for index, subnet in resource.aws_subnet.this : subnet.id ]
}

output "private_subnet_ids" {
  value = ([
    for index, subnet in resource.aws_subnet.this :
    resource.aws_subnet.this[index].id
    if resource.aws_subnet.this[index]["map_public_ip_on_launch"] == false
  ])
}

# Note that more reliable way of determinging whether subnet is public is
# by checking its routing table and verifying that traffic is routed to IGW.
output "public_subnet_ids" {
  value = ([
    for index, subnet in resource.aws_subnet.this :
    resource.aws_subnet.this[index].id
    if resource.aws_subnet.this[index]["map_public_ip_on_launch"] == true
  ])
}

output "region" {
    value = data.aws_region.current.name
}