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