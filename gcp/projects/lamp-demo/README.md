## Running gcloud locally

Instead of installing `gcloud` locally, we can use Docker container:
```
$ docker pull gcr.io/google.com/cloudsdktool/google-cloud-cli:latest
```
To verify gcloud version:
```
$ docker run --rm gcr.io/google.com/cloudsdktool/google-cloud-cli:latest gcloud version
Google Cloud SDK 483.0.0
```

## Terraform authentication with Google Cloud

We use Workload Identity Federation to authenticate Terraform with Google Cloud instead of service account keys as this is a more secure approach. This way we can use external identity providers to access Google Cloud resources without needing long-lived service account keys. In our case we use a regular Google account authentication on behalf of Terraform Google provider.

In Google Cloud console we added:
- project named `lamp-demo` (with ID = `lamp-demo-4xxxx0` and Project number = `70xxxxxxxx97`)
- service account named `terraform` with `Editor` permissions (email = `terraform@lamp-demo-4xxxx0.iam.gserviceaccount.com`)
- Workload Identity Pool named `lamp-demo-wip` with Identity Provider:
  - Type: `OIDC`
  - Name: `Google`
  - Issuer (URL): `https://accounts.google.com`
  - Attribute Mapping: Google `google.subject` to OIDC `assertion.sub`

We then allowed the identity pool to impersonate the service account by binding the `roles/iam.workloadIdentityUser` role to the principal which is in our case a regular Google account (identified by gmail email address). Adding a binding to a service account grants the specified member the specified role on the service account. (see https://cloud.google.com/sdk/gcloud/reference/iam/service-accounts/add-iam-policy-binding):

```
$ docker run --rm --volumes-from gcloud-config gcr.io/google.com/cloudsdktool/google-cloud-cli gcloud iam service-accounts add-iam-policy-binding terraform@lamp-demo-4xxxx0.iam.gserviceaccount.com --role="roles/iam.workloadIdentityUser" --member="principalSet://iam.googleapis.com/projects/70xxxxxxxx97/locations/global/workloadIdentityPools/lamp-demo-wip/attribute.sub/bojan.komazec@gmail.com" --project lamp-demo-4xxxx0
Updated IAM policy for serviceAccount [terraform@lamp-demo-4xxxx0.iam.gserviceaccount.com].
bindings:
- members:
  - principalSet://iam.googleapis.com/projects/70xxxxxxxx97/locations/global/workloadIdentityPools/lamp-demo-wip/attribute.sub/bojan.komazec@gmail.com
  role: roles/iam.workloadIdentityUser
etag: BwXXXXXXo=
version: 1
```

## Authentication process

To authenticate user with Google:

```
$ docker run -ti --name gcloud-config gcr.io/google.com/cloudsdktool/google-cloud-cli gcloud auth login
Go to the following link in your browser, and complete the sign-in prompts:

    https://accounts.google.com/o/oauth2/auth?response_type=code&client_id=32xxxxxxx59.apps.googleusercontent.com&redirect_uri=https%3A%2F%2Fsdk.cloud.google.com%2Fauthcode.html&scope=openid+https%3A%2F%2Fwww.googleapis.com%2Fauth%2Fuserinfo.email+https%3A%2F%2Fwww.googleapis.com%2Fauth%2Fcloud-platform+https%3A%2F%2Fwww.googleapis.com%2Fauth%2Fappengine.admin+https%3A%2F%2Fwww.googleapis.com%2Fauth%2Fsqlservice.login+https%3A%2F%2Fwww.googleapis.com%2Fauth%2Fcompute+https%3A%2F%2Fwww.googleapis.com%2Fauth%2Faccounts.reauth&state=HoRxxxxxxxZQYP&prompt=consent&token_usage=remote&access_type=offline&code_challenge=4UVxxxxxxxxxxxxxb2k&code_challenge_method=S256

Once finished, enter the verification code provided in your browser: 4/0AcxxxxxxxxD-A

You are now logged in as [bojan.komazec@gmail.com].
Your current project is [None].  You can change this setting by running:
  $ gcloud config set project PROJECT_ID
```

To verify that access token has been created and is present in gcloud-config volume:
```
$ docker run --rm --volumes-from gcloud-config gcr.io/google.com/cloudsdktool/google-cloud-cli gcloud auth print-access-token
```

Each time Google account gets authentiacated we need to refresh the access_token.

To pass the token value to `access_token` variable we have several options:

1) To use environment variable

We can have `print_access_token.sh` script with this content:
```
docker run --rm --volumes-from gcloud-config gcr.io/google.com/cloudsdktool/google-cloud-cli gcloud auth print-access-token
```

This script needs to be executable:
```
$ sudo chmod +x ./print_access_token.sh
```

To assign the token to environment variable:
```
$ export GOOGLE_ACCESS_TOKEN=$(./print_access_token.sh)
```
We can now use this environment variable to pass the token to Terraform provider:
```
$ terraform init -var "access_token=$GOOGLE_ACCESS_TOKEN"
$ terraform plan -var "access_token=$GOOGLE_ACCESS_TOKEN"
```

2) To use .tfvars file


```
$ echo "access_token=\"$(docker run --rm --volumes-from gcloud-config gcr.io/google.com/cloudsdktool/google-cloud-cli gcloud auth print-access-token)\"" > terraform.tfvars
```
Terraform automatically loads `terraform.tfvars` file.

We have to make sure terraform.tfvars file is included in .gitignore.