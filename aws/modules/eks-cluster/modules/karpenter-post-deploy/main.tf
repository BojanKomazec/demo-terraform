

resource "kubernetes_manifest" "karpenter_nodepool" {
  # Set to 0, run $ terraform plan
  # Then set to 1 and run again $ terraform plan
  # count = 0
  # manifest = yamldecode(file("${path.module}/files/templates/karpenter-node-pool.yaml.tftpl"))
  manifest = yamldecode(templatefile("${path.module}/files/templates/karpenter-node-pool.yaml.tftpl", {
    # manifest = templatefile("${path.module}/files/templates/karpenter-node-pool.yaml.tftpl", {
    instance_arch    = yamlencode(var.node_pool_instance.arch),
    instance_os      = yamlencode(var.node_pool_instance.os),
    instance_family  = yamlencode(var.node_pool_instance.family),
    instance_size    = yamlencode(var.node_pool_instance.size),
    node_group_names = yamlencode(var.node_group_names),
  }))

  depends_on = [
    # because nodeClassRef has EC2NodeClass as its kind
    resource.kubernetes_manifest.karpenter_ec2_nodeclass
    # module.karpenter-core
    # resource.helm_release.karpenter,
    # resource.kubernetes_manifest.karpenter_crd
  ]
}

# output "karpenter_node_pool_yaml_content" {
#   value = yamldecode(templatefile("${path.module}/files/templates/karpenter-node-pool.yaml.tftpl", {
#   # manifest = templatefile("${path.module}/files/templates/karpenter-node-pool.yaml.tftpl", {
#     instance_arch = yamlencode(var.node_pool_instance.arch),
#     instance_os =  yamlencode(var.node_pool_instance.os),
#     instance_family =  yamlencode(var.node_pool_instance.family),
#     instance_size =  yamlencode(var.node_pool_instance.size),
#     node_group_name = var.node_group_name,
#   }))
# }

# Having even commented this section:
#
#   amiSelectorTerms:
#     - id: "${ARM_AMI_ID}"
#     - id: "${AMD_AMI_ID}"
#   - id: "${GPU_AMI_ID}" # <- GPU Optimized AMD AMI
#   - name: "amazon-eks-node-${K8S_VERSION}-*" # <- automatically upgrade when a new AL2 EKS Optimized AMI is released. This is unsafe for production workloads. Validate AMIs in lower environments before deploying them to production.
#
# ...in template file gives error:
# │ Invalid value for "vars" parameter: vars map does not contain key "ARM_AMI_ID", referenced at
# │ ../../modules/eks-cluster/modules/karpenter-post-deploy/files/templates/karpenter-EC2NodeClass.yaml.tftpl:16,16-26.
resource "kubernetes_manifest" "karpenter_ec2_nodeclass" {
  #count = 0
  manifest = yamldecode(templatefile("${path.module}/files/templates/karpenter-EC2NodeClass.yaml.tftpl", {
    karpenter_node_role_name = var.karpenter_node_role_name,
    cluster_name             = var.cluster_name
  }))
  # depends_on = [
  # 	# resource.kubernetes_manifest.karpenter_nodepool
  # 	module.karpenter-core
  # ]
}