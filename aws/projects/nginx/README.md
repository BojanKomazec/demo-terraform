To connect to the cluster you need to update the Kubernetes context with this command.
```
$ aws eks update-kubeconfig --name <cluster_name> --region <region>
```
For example:
```
$ aws eks update-kubeconfig --name nginx-cluster --region eu-west-2
```
Then the quick check if we can reach Kubernetes. It should return the default k8s service.
```
kubectl get svc
```

bojan@bobox:~/Downloads/helm-v3.15.1-linux-amd64/linux-amd64$ ./helm list -A
NAME     	NAMESPACE	REVISION	UPDATED                                	STATUS  	CHART           	APP VERSION
karpenter	karpenter	1       	2024-06-10 23:36:12.827819185 +0100 BST	deployed	karpenter-0.16.3	0.16.3
bojan@bobox:~/Downloads/helm-v3.15.1-linux-amd64/linux-amd64$ kubectl get pods -n karpenter
NAME                         READY   STATUS    RESTARTS   AGE
karpenter-6c4fb588cb-2gznl   2/2     Running   0          4m58s
karpenter-6c4fb588cb-4b2pv   0/2     Pending   0          4m58s

bk_aws3/modules/eks-cluster$ kubectl apply -f provisioner-karpenter.yaml
provisioner.karpenter.sh/default created
awsnodetemplate.karpenter.k8s.aws/my-provider created

# TODO
- Use https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/availability_zones instead of hardcoding AZs.

