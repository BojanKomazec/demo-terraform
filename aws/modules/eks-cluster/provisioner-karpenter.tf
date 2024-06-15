# resource "local_file" "karpenter_provisioner" {
#     filename = "${path.module}/karpenter-default-provisioner.yaml"
#     content = yamlencode({
#     })
# }