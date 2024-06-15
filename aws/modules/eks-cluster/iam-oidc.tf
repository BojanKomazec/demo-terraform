#
# ==============================================
# OIDC and IAM Roles for Service Accounts (ARSA)
# ==============================================
#
#
# A Kubernetes service account (SA) provides an identity for processes that run
# in a Pod. SA is a type of Kubernetes entity.
#
# When Pods contact the API server, they authenticate as a particular
# ServiceAccount (for example, 'default'). There is always at least one
# ServiceAccount in each namespace. Every Kubernetes namespace contains at least
# one ServiceAccount: the default ServiceAccount for that namespace, named
# 'default'. If we do not specify a ServiceAccount when we create a Pod,
# Kubernetes automatically assigns the ServiceAccount named 'default' in that
# namespace.
#
# We can create a non-default Service Account.
#
# We can configure the Pod to use a non-default Service Account (to attach a
# Service Account to it).
#
# JSON Web Token (JWT) is a string built with 2 JSON objects encoded in base64
# and a signature; these parts are joined by a period (.) with the following
# structure: <header>.<payload>.<signature>.
#
# JWT always starts with ey, because it is the result of encoding {" using
# base64, which is the beginning of any JSON.
#
# In the header part we can find which signature algorithm was used in the alg
# parameter (e.g. RS256) to sign the JWT, and the kid parameter tells which
# Key ID from the JSON Web Key Set (JWKS) was used for a given token.
# When the JWT header has a Key ID (kid), JWKS is used.
# The issuer is the one who created and signed the JWT, and we can know this by
# checking the value iss in the payload of our JWT.
# To create the signature part, you need to take the encoded header, encoded
# payload, a secret, and the algorithm specified in the header, then sign that
# with the secret. The signature is used to verify that the sender of the JWT
# is who it says it is and to ensure that the message wasn’t changed along the
# way.
#
# When a new EKS cluster is created, it contains:
#  - its own OpenId Connect (OIDC) Provider which:
#    - exposes Discovery endpoint: https://oidc.eks.<region>.amazonaws.com/id/<uniquie_id>/.well-known/openid-configuration
#      which returns JSON which has property jwks_uri which is url of TLS public
#      key which will later be used to verify OIDC JWT (Json Web Token) which is
#      signed with the private key of the same key pair.
#  - https://github.com/aws/amazon-eks-pod-identity-webhook controller which
#    mutates pods that contain annotation that they will require some IAM Role:
#    - when SA is created, it creates for it a Service Account Token which is
#      OICD JWT, stored as K8s Secret in the same namespace
#    - JWT is encrypted with OIDC Provider's private key
#    - when Pod is configured to use particular SA, it mounts SA JWT volume onto
#      pod at /var/run/secrets/eks.amazonaws.com/serviceaccount/token
#    - it injects two environment variables into the containers running in the
#      pod:
#      - AWS_ROLE_ARN - the IAM Role ARN pod should use
#      - AWS_WEB_IDENTITY_TOKEN_FILE - path to the token it should use to try
#      to assume the above role.
#
# Before pod can access AWS resource (AWS API) it needs to assume required
# IAM Role. IAM Role has attached to it:
# - trust relation policy (defines WHO can assume this role)
# - access policy (WHAT can the role assumer/owner do)
#
# When some process from Pod needs to call AWS API it will do that via AWS SDK.
# AWS SDK looks those env vars and sends sts:AsumeRoleWithWebIdentity request
# which contains the ARN or role it wants to assume and JWT.
# STS then:
# - uses OIDC provider discovery endpoint and jwks_uri to obtain public
#   key and verify/validate JWT (by decrypting it with public key). This is to
#   ensure the presented service account JWT is valid and issued by the trusted
#   cluster’s OIDC Provider
# - checks if IAM Role allows to be assumed by the identity (Kubernetes SA)
#   from JWT (checks if SA is trusted)
# - issues security credentials for IAM Role to the application in Pod.
#
# This last step effectively attaches IAM Role to the pod configured to use SA.
#

# We need to create IAM Identity Provider of OIDC type which will be
# representing EKS cluster OIDC IdP.
# https://docs.aws.amazon.com/eks/latest/userguide/enable-iam-roles-for-service-accounts.html
#
# (Don't mix this provider with the one that can be created for external OIDC
# providers, described here:
# https://docs.aws.amazon.com/IAM/latest/UserGuide/id_roles_providers_create_oidc.html)
#
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_openid_connect_provider
#
# In our case, the Client of the IdP is AWS Security Token Service (AWS STS) as
# it uses IdP to verify the identity of the Kubernetes ServiceAccount.
#
# IRSA (and so OIDC) need to be enabled if we want to user Karpenter instead of
# the Kubernetes Cluster Autoscaler.
#

resource "aws_iam_openid_connect_provider" "eks" {
  # (Required) The URL of the identity provider. Corresponds to the iss
  # (issuer) claim.
  url = aws_eks_cluster.this.identity[0].oidc[0].issuer

  # (Required) A list of server certificate thumbprints for the
  # OIDC identity provider's server certificate(s).
  thumbprint_list = [data.tls_certificate.eks_oidc.certificates[0].sha1_fingerprint]

  # (Required) A list of client IDs (also known as audiences). When a mobile
  # or web app registers with an OpenID Connect provider, they establish a
  # value that identifies the application. (This is the value that's sent as
  # the client_id parameter on OAuth requests.)
  client_id_list = ["sts.amazonaws.com"]
}

# Requires TLS provider
# https://registry.terraform.io/providers/hashicorp/tls/latest/docs
data "tls_certificate" "eks_oidc" {
  url = aws_eks_cluster.this.identity[0].oidc[0].issuer
}