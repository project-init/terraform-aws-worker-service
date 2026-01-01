module "worker" {
  source = "project-init/worker-service/aws"
  # Project Init recommends pinning every module to a specific version
  # version = "vX.X.X"
}
