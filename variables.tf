
################### Lambda PRovisioning Specific Variables ###################
variable "runtime" {
  default = "python3.9"
}
variable "region" {
  default = "us-east-2"
}
variable "aws_profile" {
  default = "nasuni"
}
variable "admin_secret" {
  default = "nct/nce/os/admin"
}
variable "internal_secret" {
  default = "nac-es-internal"
}

#########################################