This module provisions typical foundational networking resources in a specific
region and environment.

To understand the architecture please read the .tf config files in this order:
- vpc
- subnets
- igw
- nat
- routing

# TODO
- Introduce using terraform workspaces named after current environment so
environment can be retrieved via ${terraform.workspace} interpolation.