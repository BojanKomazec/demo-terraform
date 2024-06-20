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

	person = {
		Name = "Bojan"
		Surname = "Komazec"
	}

	# To access map's values we can use key with . or [] notation:
	person_name = local.person.Name
	person_name_2 = local.person["Name"]

	test_user_name = "test_user"
	test_user_roles = [ "ContentReader", "CommentReader", "CommentWriter" ]

	yaml_template_file_content = templatefile("${path.module}/files/templates/test.yaml.tftpl", {
		user_name = local.test_user_name
		roles = local.test_user_roles
		version = "1.0.0"
	})
}