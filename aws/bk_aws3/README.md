After provisioning resources (`terraform apply`) but before using kubectl to deploy the application into the cluster, configure kubectl so it points to AWS EKS cluster:
```
$ aws eks --region <region> update-kubeconfig --name example-voting-app --profile=<profile_name>
```
e.g.
```
$ aws eks --region eu-west-2 update-kubeconfig --name example-voting-app --profile=terraform
```