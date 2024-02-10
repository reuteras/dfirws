variable "autounattend" {
  type    = string
  default = "./resources/vm/answer_files/Autounattend.xml"
}

variable "cpus" {
  type    = string
  default = "4"
}

variable "disk_size" {
  type    = string
  default = "307200"
}

variable "disk_type_id" {
  type    = string
  default = "1"
}

variable "headless" {
  type    = string
  default = "false"
}

variable "username" {
  type    = string
  default = "dfirws"
}

variable "password" {
  type    = string
  default = "password"
}

variable "memory" {
  type    = string
  default = "16384"
}

variable "restart_timeout" {
  type    = string
  default = "5m"
}

variable "vhv_enable" {
  type    = string
  default = "false"
}

variable "output_directory" {
  type    = string
  default = "~/Windows_11_dfirws_64-bit.vmwarevm"
}

variable "vm_name" {
  type    = string
  default = "Windows_11_dfirws_64-bit"
}

variable "winrm_timeout" {
  type    = string
  default = "6h"
}