#
# Execute terraform init, plan, apply and destroy and observe outputs.
# Observe order of creation of resources in terraform apply. The output should be like:
#
#   local_file.water: Creating...
#   local_file.water: Creation complete after 0s [id=6d5a45920a15adea049c8f22d569ff209625a43b]
#   local_file.plant: Creating...
#   local_file.plant: Creation complete after 0s [id=baf0bf92eb79156bdc34cddba390e31738b942f1]
#
#

resource "local_file" "plant" {
    filename="${path.cwd}/temp/plant"
    content="plant"
    depends_on = [
        local_file.water
    ]
}

resource "local_file" "water" {
    filename="${path.cwd}/temp/water"
    content="water"
}