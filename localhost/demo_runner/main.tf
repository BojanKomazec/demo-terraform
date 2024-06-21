module "download_yaml_file" {
	count = 0
  source = "./modules/file_download"
  file = {
    url  = "https://raw.githubusercontent.com/aws/karpenter-provider-aws/v0.37.0/pkg/apis/crds/karpenter.sh_nodepools.yaml"
    type = "yaml"
    path = "${path.module}/tmp/karpenter.sh_nodepools.yaml"
  }
}

module "download_yaml_files" {
	# Error: The given "for_each" argument value is unsuitable: the "for_each"
	# argument must be a map, or set of strings, and you have provided a value of
	# type tuple.
	# for_each = local.urls
	# for_each = toset(local.urls)
	for_each = {} # empty set - use it to omit provisioning this module

  source = "./modules/file_download"

  file = {
    url  = each.value
    type = "yaml"
    path = "${path.module}/tmp/${regex("/([^/]*)$", each.value)[0]}"
  }
}

module "meta_args_demo" {
	count = 0
	source = "./modules/meta_args_demo"
	# tmp_dir_path = "${path.cwd}"
	dest_dir_path = "${path.module}/tmp/"
}

module "expressions_demo" {
  count = 1
  source = "./modules/expressions_demo"
  name = var.name
  surname = var.surname
}