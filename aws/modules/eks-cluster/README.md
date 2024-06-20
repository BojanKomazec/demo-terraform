After provisioning resources (`terraform apply`) but before using kubectl to
connect to cluster in order to e.g. list all pods or deploy the application into
the cluster, we need to update the Kubernetes context (configure kubectl so it
points to specific AWS EKS cluster):
```
$ aws eks update-kubeconfig --region <region> --name <cluster_name> --profile=<profile_name>
```
e.g.
```
$ aws eks update-kubeconfig --region eu-west-2 --name example-voting-app --profile=terraform
```
As a test that kubectl can reach the cluster, we can try to list services in the
cluster (default Kubernertes service should be listed):
```
$ kubectl get svc
```

If you want to check the cluster details in AWS Console and there you get an
error "Your current IAM principal doesn’t have access to Kubernetes objects on
this cluster." then you need to add this principal to aws-auth config map (if
config map is used to controll the access to cluster):

```
$ kubectl edit configmap aws-auth -n kube-system
```
...and insert the following (at the same level as `mapRoles`, under `data`):
```
  mapUsers: |
    - userarn: arn:aws:iam::XXXXXXXXXXXX:user_name
      groups:
      - system:masters
```


To see the Karpenter log:
```
kubectl logs -f -n kube-system -l app.kubernetes.io/name=karpenter -c controller
```


# ToDo:
- group input variables under two input variables: cluster and node_group