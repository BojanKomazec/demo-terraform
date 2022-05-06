# To install Graphviz on Linux:
#   $ apt update && apt install graphviz -y
# To install Graphviz on Mac:
#   % brew install graphviz
# Command to create a graph image is same on Linux and Mac:
#   % terraform graph | dot -Tsvg > graph.svg

resource "random_pet" "my_random_text" {
    length = 2
    prefix = "my_rnd_txt_"
    separator = "."
}

resource "local_file" "foo" {
    filename = "${path.cwd}/temp/foo.txt"
    content = "Let's use the random_pet output which is id with value ${random_pet.my_random_text.id}"
}
