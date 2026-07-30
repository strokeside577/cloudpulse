terraform {
  backend "gcs" {
    bucket = "cloudpulse-terraform-state"
    prefix = "terraform/state"
  }
}
