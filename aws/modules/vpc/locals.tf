locals {
	is_nat_required = var.nat_gw == null ? false : true
}