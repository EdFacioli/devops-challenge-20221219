module "s3" {
  source = "./modules/s3"

  environment_id = var.environment_id
  appName        = var.appName

}
