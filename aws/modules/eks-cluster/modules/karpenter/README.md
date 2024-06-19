This module installs Karpenter auto-scaler onto the given AWS EKS cluster.

The following resources get created:
- IAM role for nodes provisioned by Karpenter: KarpenterNodeRole-<cluster_name>
- IAM role for Karpenter controller: KarpenterControllerRole-<cluster_name>
- All subnets used in all node groups get a new tag: "karpenter.sh/discovery":<cluster_name>
- Default security group (associated with the EKS cluster) gets a new tag: "karpenter.sh/discovery":<cluster_name>
- aws-auth ConfigMap is updated in order to allow nodes that are using the node IAM role to join the cluster
- Karpenter is installed (as a Helm chart)
