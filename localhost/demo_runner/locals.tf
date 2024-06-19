locals {
	version = "0.36.0"

 	urls = [
    "https://raw.githubusercontent.com/aws/karpenter-provider-aws/v${local.version}/pkg/apis/crds/karpenter.sh_nodepools.yaml",
    "https://raw.githubusercontent.com/aws/karpenter-provider-aws/v${local.version}/pkg/apis/crds/karpenter.k8s.aws_ec2nodeclasses.yaml",
    "https://raw.githubusercontent.com/aws/karpenter-provider-aws/v${local.version}/pkg/apis/crds/karpenter.sh_nodeclaims.yaml",
  ]

	# This captures leading '/' as well
	# regex_expr = "/[^/]*$"

	# Only capturing group match is returned (which is a file name)
	regex_expr = "/([^/]*)$"

  file_names = [for url in local.urls : regex(local.regex_expr, url)]
}