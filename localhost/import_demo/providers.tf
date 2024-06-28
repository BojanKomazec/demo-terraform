provider "docker" {
  # Configuration options

  # Unix socket the Docker daemon listens on by default.
  # On Windows, this would be: "tcp://localhost:2375"
  host = "unix:///var/run/docker.sock"
}