variable "iso_path" {
    # Required variable
    type = string
    description = "Full local path to downloaded Winows 10 ISO"
}

variable "iso_checksum" {
    # Required variable
    type = string
    description = "SHA256 hash of ISO. Can use powershell Get-FileHash to get a SHA256 hash"
}

variable "username" {
    # Optional variable
    type = string
    description = "Name of user account to create on the VM. Defaults to vagrant"
    default = "vagrant"
}

variable "password" {
    # Optional variable
    type = string
    description = "Password for user account created on the VM. Defaults to vagrant"
    default = "vagrant"
}

variable "export_path" {
    # Optional variable
    type = string
    description = "Path to save vagrantfile and .box. Defaults to same directory as packer template"
    default = "./export"
}
