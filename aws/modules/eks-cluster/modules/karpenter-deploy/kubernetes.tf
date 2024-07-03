# In order to allow nodes that are using the node IAM role KarpenterNodeRole
# to join the cluster we have to modify the aws-auth ConfigMap in the cluster.
# The full aws-auth configmap should have two groups: one for our Karpenter node
# role and one for our existing node group.
# See: https://karpenter.sh/docs/getting-started/migrating-from-cas/#update-aws-auth-configmap
#
# We'll try to use this resorce instead of the manual intervention:
# kubectl edit configmap aws-auth -n kube-system
#
# https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/config_map
#
# │ Error: Field manager conflict
# │
# │   with module.nginx-eks-karpenter-deploy.kubernetes_config_map_v1_data.config_map_aws_auth,
# │   on ../../modules/eks-cluster/modules/karpenter-deploy/kubernetes.tf line 11, in resource "kubernetes_config_map_v1_data" "config_map_aws_auth":
# │   11: resource "kubernetes_config_map_v1_data" "config_map_aws_auth" {
# │
# │ Another client is managing a field Terraform tried to update. Set "force" to true to override: Apply failed with 1 conflict: conflict with "vpcLambda" using v1:
# │ .data.mapRoles
#
# There should only be one aws-auth ConfigMap in the cluster, specifically
# located in the kube-system namespace.
resource "kubernetes_config_map_v1_data" "config_map_aws_auth" {
  metadata {
    name      = "aws-auth"
    namespace = "kube-system"
  }

  # Force overwriting data that is managed outside of Terraform.
  force = true

  # The data we want to add to the ConfigMap.
  data = {
    mapRoles = local.map_roles
  }

  depends_on = [aws_iam_role.karpenter-node]
}


# Before deploying Karpenter to EKS cluster we need to execute the following:
# kubectl create namespace "${KARPENTER_NAMESPACE}" || true
# kubectl create -f \
#     "https://raw.githubusercontent.com/aws/karpenter-provider-aws/v${KARPENTER_VERSION}/pkg/apis/crds/karpenter.sh_nodepools.yaml"
# kubectl create -f \
#     "https://raw.githubusercontent.com/aws/karpenter-provider-aws/v${KARPENTER_VERSION}/pkg/apis/crds/karpenter.k8s.aws_ec2nodeclasses.yaml"
# kubectl create -f \
#     "https://raw.githubusercontent.com/aws/karpenter-provider-aws/v${KARPENTER_VERSION}/pkg/apis/crds/karpenter.sh_nodeclaims.yaml"
#
# Only then we can do:
# kubectl apply -f karpenter.yaml
# ...which we'll do here via Helm.

# locals {
#   # CustomResourceDefinition files
#   karpenter_crd_urls = [
#     "https://raw.githubusercontent.com/aws/karpenter-provider-aws/v${var.karpenter_version}/pkg/apis/crds/karpenter.sh_nodepools.yaml",
#     "https://raw.githubusercontent.com/aws/karpenter-provider-aws/v${var.karpenter_version}/pkg/apis/crds/karpenter.k8s.aws_ec2nodeclasses.yaml",
#     "https://raw.githubusercontent.com/aws/karpenter-provider-aws/v${var.karpenter_version}/pkg/apis/crds/karpenter.sh_nodeclaims.yaml",
#   ]

#   # karpenter_crds = {
#   #   "https://raw.githubusercontent.com/aws/karpenter-provider-aws/v${var.karpenter_version}/pkg/apis/crds/karpenter.sh_nodepools.yaml" = "karpenter.sh_nodepools.yaml",
#   #   "https://raw.githubusercontent.com/aws/karpenter-provider-aws/v${var.karpenter_version}/pkg/apis/crds/karpenter.k8s.aws_ec2nodeclasses.yaml" = "karpenter.k8s.aws_ec2nodeclasses.yaml",
#   #   "https://raw.githubusercontent.com/aws/karpenter-provider-aws/v${var.karpenter_version}/pkg/apis/crds/karpenter.sh_nodeclaims.yaml" = "karpenter.sh_nodeclaims.yaml",
#   # }


#   #
#   # karpenter_crd_file_names = [for url in local.karpenter_crd_urls : regex("/([^/]*)$", url)]
#   karpenter_crd_file_names = [
#     "karpenter.sh_nodepools.yaml",
#     "karpenter.k8s.aws_ec2nodeclasses.yaml",
#     "karpenter.sh_nodeclaims.yaml",
#   ]
# }

# data "http" "file" {
#   for_each = toset(local.karpenter_crd_urls)
#   url = each.key

#   # for_each = local.karpenter_crds
#   # url = each.value

#   # Optional request headers
#   request_headers = {
#     Accept = "application/yaml"
#   }

#   lifecycle {
#     # Terraform checks a precondition before evaluating the object it is
#     # associated with and checks a postcondition after evaluating the object.
#     postcondition {
#       # condition argument. This is an expression that must return true if the
#       # conditition is fufilled or false if it is invalid.
#       condition = contains([200], self.status_code)

#       # If the condition evaluates to false, Terraform will produce an error
#       # message
#       error_message = "Status code invalid"
#     }
#   }
# }

# locals {
#   karpenter_crd = jsondecode(data.http.ifconfig.body)
# }


# resource "local_file" "karpenter_crd" {
#   for_each = data.http.file
#   content  = each.value.response_body
#   filename = "${path.module}/files/${regex("/([^/]*)$", each.value.id)[0]}"
#   # filename = "${path.module}/files/${local.karpenter_crds[each.value.id]}"
# }

# resource "kubernetes_manifest" "karpenter_crd" {
#   for_each = local_file.karpenter_crd
#   manifest = yamldecode(file("${each.value.filename}"))
#   # for_each = local.karpenter_crds
#   # manifest = yamldecode(file("${each.value.filename}"))
#   depends_on = [ local_file.karpenter_crd ]
# }

#
# │ Error: Failed to construct REST client
# │  114: resource "kubernetes_manifest" "karpenter_crd" {
# │ cannot create REST client: no client config
#
# The kubernetes_manifest resource needs access to the cluster's API server of
# the cluster during planning.
# https://github.com/hashicorp/terraform-provider-kubernetes/issues/1775#issuecomment-1193859982
#
# │ Invalid value for "path" parameter: no file exists at "../../../../modules/eks-cluster/modules/karpenter/files/karpenter.k8s.aws_ec2nodeclasses.yaml"; this function
# │ works only with files that are distributed as part of the configuration source code, so if this file will be created by a resource in this configuration you must instead
# │ obtain this result from an attribute of that resource.
#
# We need to apply these CRD definitions before we deploy CRDs themselves (e.g.
# NodePool kind)
# resource "kubernetes_manifest" "karpenter_crd" {
#   # for_each = toset(local.karpenter_crd_file_names)
#   # for_each = local.karpenter_crdsfor_each = data.http.file
#   for_each = data.http.file
#   # manifest = yamldecode(file("${path.module}/files/${each.value}"))
#   # manifest = yamldecode(file("${each.value.filename}"))
#   manifest = yamldecode(each.value.response_body)
#   # depends_on = [ local_file.karpenter_crd ]
# }


# ╷
# │ Error: API did not recognize GroupVersionKind from manifest (CRD may not be installed)
# │
# │   with module.nginx-eks-karpenter.kubernetes_manifest.karpenter_nodepool,
# │   on ../../../../modules/eks-cluster/modules/karpenter/kubernetes.tf line 133, in resource "kubernetes_manifest" "karpenter_nodepool":
# │  133: resource "kubernetes_manifest" "karpenter_nodepool" {
# │
# │ no matches for kind "NodePool" in group "karpenter.sh"

# resource "kubernetes_manifest" "karpenter_nodepool" {
#   # Set to 0, run $ terraform plan
#   # Then set to 1 and run again $ terraform plan
#   count = 0
#   manifest = yamldecode(file("${path.module}/files/templates/karpenter-node-pool.yaml.tftpl"))
#   depends_on = [
#     resource.helm_release.karpenter,
#     # resource.kubernetes_manifest.karpenter_crd
#   ]
# }

# resource "kubernetes_manifest" "karpenter_ec2_nodeclass" {
#   count = 0
#   manifest = yamldecode(file("${path.module}/files/templates/karpenter-EC2NodeClass.yaml.tftpl"))
#   depends_on = [ resource.kubernetes_manifest.karpenter_nodepool ]
# }
