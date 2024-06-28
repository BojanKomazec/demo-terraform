This project demonstrates how to bring the existing infrastructure under Terraform management. It is inspired by https://developer.hashicorp.com/terraform/tutorials/state/state-import.

Provided `docker-compose.yaml` supports using Terraform Docker container on the development host (for those who prefer it over installing Terraform locally).

To use this demo project please follow these steps:

Start the e.g. Nginx container:
```
$ docker run --name nginx --detach --publish "0.0.0.0:8080:80" nginx:latest
```
Find out the ID of the container:
```
$ docker inspect --format="{{ .ID }}" nginx
```
Use this id in the `id` attribute of the `import` block.

To prevent the necessity of chaning the code itself, we can use input variable
and set it from the command line:
```
$ docker compose run --rm terraform plan -var nginx_docker_container_id=$(docker inspect --format='{{ .ID }}' nginx) -generate-config-out=generated.tf
```

The command above outputs:
```
  # Warning: this will destroy the imported resource
-/+ resource "docker_container" "nginx" {
	...
	image                                       = "sha256:e0c9858e10ed8be697dc2809db78c57357ffc82de88c69a3dee5d148354679ef"
	...
    name                                        = "nginx"
	...
  + env                                         = (known after apply) # forces replacement
    ...
Plan: 1 to import, 1 to add, 0 to change, 1 to destroy.
```
We'll preserve only those attributes that are required in resource "docker_container".

If we run the same command again, we'll get:

```
Error: Target generated file already exists
```
So, let's omit -generate-config argument:

```
$ docker compose run --rm terraform plan -var nginx_docker_container_id=$(docker inspect --format='{{ .ID }}' nginx) 
```

This command now outputs:

```
  # Warning: this will destroy the imported resource
-/+ resource "docker_container" "nginx" {
    ...
    - network_mode                                = "bridge" -> null # forces replacement
	...
Plan: 1 to import, 1 to add, 0 to change, 1 to destroy.
```

So, let's also leave network_mode attribute so generated.tf looks like:
```
# __generated__ by Terraform
# Please review these resources and move them into your main configuration files.

# __generated__ by Terraform from "65cc117a28f17f8cb06da4bc9f00a005a2da291acd5b26a7b3e74899fd60a515"
resource "docker_container" "nginx" {
  env                                         = []
  image                                       = "sha256:e0c9858e10ed8be697dc2809db78c57357ffc82de88c69a3dee5d148354679ef"
  name                                        = "nginx"
  network_mode                                = "bridge" 
  ports {
    external = 8080
    internal = 80
    ip       = "0.0.0.0"
    protocol = "tcp"
  }
}
```
We now have:
```
$ docker compose run --rm terraform plan -var nginx_docker_container_id=$(docker inspect --format='{{ .ID }}' nginx) 
...
Terraform will perform the following actions:

  # docker_container.nginx will be updated in-place
  # (imported from "65cc117a28f17f8cb06da4bc9f00a005a2da291acd5b26a7b3e74899fd60a515")
  ~ resource "docker_container" "nginx" {
  ...
    }

Plan: 1 to import, 0 to add, 1 to change, 0 to destroy.
```
We can now use apply:
```
$ docker compose run --rm terraform apply -var nginx_docker_container_id=$(docker inspect --format='{{ .ID }}' nginx) -auto-approve
...
Apply complete! Resources: 1 imported, 0 added, 1 changed, 0 destroyed.
```

From https://developer.hashicorp.com/terraform/language/import:
```
The import block records that Terraform imported the resource and did not create it. After importing, you can optionally remove import blocks from your configuration or leave them as a record of the resource's origin.
```

This makes me think that it would have been totally OK (and actually highly desireable) to use hardcoded `id` value in `import` block as it would store permanently the id of the imported resource. Regardless, passing the variable via command line was a good exercise.


To debug container issues:
- In `docker-compose.yaml` set `entrypoint` to desired command e.g. `ping`
- run: `docker compose run --rm terraform`