# This enables the following GuardDuty protection plans:
# - EKS Protection: monitoring EKS audit logs
# - Malware Protection for EC2:
#   - EC2 instances
#   - EBS volumes
# - RDS Protection
# - S3 Protection: S3 logs
# - Lambda Protection
#
# Runtime Monitoring plan does NOT get enabled!
# GuardDuty is a regional service and thus must be enabled in each region that you are using.
# BK: There can be only one detector per region.
resource "aws_guardduty_detector" "this" {
  enable = false
}


# I opted to keep this resource in guardduty module (not int eks-cluster module) because GuardDuty is external service and
# we might want to have EKS Runtime monitoring included through RUNTIME_MONITORING rather than EKS_RUNTIME_MONITORING and
# enabling RUNTIME_MONITORING should not be controlled from eks-cluster module but gobally, from guardduty service module.
#
# This resource can be provisioned only if aws_guardduty_detector is enabled.
# If we try to provision it while aws_guardduty_detector is disabled, we'll get an error:
# Error: updating GuardDuty Detector Feature (RUNTIME_MONITORING): BadRequestException: The request failed because you cannot
# enable a data source while the detector is disabled.
resource "aws_guardduty_detector_feature" "eks_runtime_monitoring" {

  # (Required) Amazon GuardDuty detector ID.
  detector_id = aws_guardduty_detector.this.id

  # (Required) The name of the detector feature.
  # Valid values are listed here: https://docs.aws.amazon.com/guardduty/latest/APIReference/API_DetectorFeatureConfiguration.html
  # Valid Values: S3_DATA_EVENTS | EKS_AUDIT_LOGS | EBS_MALWARE_PROTECTION | RDS_LOGIN_EVENTS | EKS_RUNTIME_MONITORING | LAMBDA_NETWORK_LOGS | RUNTIME_MONITORING
  # Specifying both EKS Runtime Monitoring (EKS_RUNTIME_MONITORING) and Runtime Monitoring (RUNTIME_MONITORING) will cause an error.
  # You can add only one of these two features because Runtime Monitoring already includes the threat detection for Amazon EKS resources.
  name        = "EKS_RUNTIME_MONITORING"

  # (Required) The status of the detector feature.
  status      = "DISABLED"

  # # (Optional) Additional feature configuration block.
  # additional_configuration {
  #   # (Required) The name of the additional configuration.
  #   # https://docs.aws.amazon.com/guardduty/latest/APIReference/API_DetectorAdditionalConfiguration.html
  #   # Valid Values: EKS_ADDON_MANAGEMENT | ECS_FARGATE_AGENT_MANAGEMENT | EC2_AGENT_MANAGEMENT
  #   # "EKS_ADDON_MANAGEMENT" equivalent in AWS Console:
  #   # GuardDuty >> Protection Plans >> Runtime Monitoring >> Automated Agent Configuration
  #   # Configure GuardDuty to automatically deploy and update the security agent in accounts where Runtime Monitoring is enabled.
  #   name   = "EKS_ADDON_MANAGEMENT"

  #   # (Required) The status of the additional configuration.
  #   # status = "ENABLED"
  #   status = "DISABLED"
  # }
}