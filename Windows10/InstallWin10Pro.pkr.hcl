packer {
    required_plugins {
        windows-update = {
          version = "0.14.3"
          source = "github.com/rgl/windows-update"
        }
        virtualbox = {
            version = ">= 1.0.4"
            source = "github.com/hashicorp/virtualbox"    
        }
        vagrant = {
            version = ">= 1.0.3"
            source  = "github.com/hashicorp/vagrant"
        }
    }
}
source "virtualbox-iso" "Win10Pro" {
    # Installation media settings
    iso_checksum = "${var.iso_checksum}"
    iso_url = "${var.iso_path}"
    iso_interface = "ide" # Required for EFI boot
    # VirtualBox VM settings
    firmware = "efi"
    guest_os_type = "Windows10_64"
    cpus = 4
    memory = 4094
    hard_drive_interface = "sata" # Use SATA for install. It runs faster than default IDE
    headless = false
    boot_command = ["a<wait>a<wait>a<wait>a"]
    boot_wait = "1s"
    cd_files = [
        "./unattend/Autounattend.xml",
        "./unattend/sysprep_unattend.xml",
        "./scripts"
        ]
    guest_additions_mode = "disable" # Guest additions are installed with Chocolatey
    communicator = "winrm"
    winrm_username = "${var.username}"
    winrm_password = "${var.password}"
    winrm_use_ntlm = true
    winrm_timeout = "6h"
    disable_shutdown = true
    shutdown_timeout = "2h"
}

build {
    name = "Win10Install"
    sources = ["virtualbox-iso.Win10Pro"]

    /*
    provisioner "windows-update" {
        # Run Windows updates. This will reboot the machine automatically
    }
*/
/*
    provisioner "powershell" {
        # Install Chocolatey
        script = "./scripts/chocolatey.ps1"
    }
    provisioner "powershell" {
        # Install guest additions
        script = "./scripts/InstallGuestAdditions.ps1"
    }

    provisioner "windows-restart" {
        # Reboot windows after installing guest additions
    }

    provisioner "powershell" {
        # Install software with chocolatey
        script = "./scripts/InstallApps.ps1
    }
*/

    # Add more provisioners to run additional scripts...
    # Once all provisioners run, packer will send the shutdown_command, which runs sysprep

    provisioner "windows-shell" {
        script = "./scripts/sysprep.bat"
        valid_exit_codes = ["0", "16001"]
    }

    post-processor "vagrant" {
        # Export VM to a .box
        output = "${var.export_path}/packer_{{.BuildName}}_{{.Provider}}"
    }
}


# Hyper-V builder settings. Documentation for the various settings can be found here:
# https://developer.hashicorp.com/packer/plugins/builders/hyperv
# Source code for the builder may also be useful: https://github.com/hashicorp/packer-plugin-hyperv
# This template uses the "hyperv-iso" builder, which is meant to install a fresh OS from an ISO
# NONE OF THIS WORKS WITHOUT MANUAL INTERVENTION DURING BOOT PROCESS. HYPER-V BOOTS TOO FAST FOR PACKER TO HANDLE
# I gave up... It all works, I just have to manually boot the VM
source "hyperv-iso" "install-windows" {
    iso_url = var.iso_path
    iso_checksum = "sha256:${var.iso_checksum}"
    memory = 4094
    cpus = 4
    switch_name = "${var.switch_name}"
    generation = 2
    enable_dynamic_memory = true
    enable_secure_boot = false
    headless = true
    boot_command = ["a<enter>a<enter>a<enter>a<enter>a<enter>"]
    boot_wait = "-1s"
    # Creates and mounts a CD to store scripts and unattend files
    cd_files = [
        "./unattend/Autounattend.xml",
        "./unattend/sysprep_unattend.xml",
        "./scripts"
        ]
    cd_label = "unattend"
    communicator = "winrm"
    winrm_username = "${var.username}"
    winrm_password = "${var.password}"
}
