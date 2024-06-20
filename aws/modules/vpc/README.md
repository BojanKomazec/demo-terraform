VPC will be created in the region specified within "aws" provider settings which
are defined in the calling module e.g.

```
provider "aws" {
  # Configuration options
  profile = "terraform"

  # London
  region = "eu-west-2"
}
```

Region specified here overrides the region specified for the same profile in
~/.aws/config.

