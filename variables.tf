variable "cidr" {
  default = "172.16.0.0/16"
  
}

variable "public_cidr" {
  type = "list"
  default = {"172.16.1.0/24,"172.16.2.0/24"}

}

variable "private_cidr" {
  type = "list"
  default = {"172.16.3.0/24,"172.16.2.0/24"}

}