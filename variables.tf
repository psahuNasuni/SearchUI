
################### Lambda Provisioning Specific Variables ###################
variable "runtime" {
  default = "python3.6"
}
variable "region" {
  default = "us-east-2"
}
variable "aws_profile" {
  default = "nasuni"
}
variable "admin_secret" {
  default = "nasuni-labs-os-admin-2"
}
variable "internal_secret" {
  default = ""
}
variable "stage_name" {
  default = "dev"
  description = "api stage name"
}
#########################################
