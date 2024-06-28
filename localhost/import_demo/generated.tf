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
