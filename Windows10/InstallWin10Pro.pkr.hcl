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
    # Use SATA for install. It runs faster than default IDE
    hard_drive_interface = "sata" 
    # Headless mode builds would fail for me often.
    headless = false 
    boot_command = ["a<wait>a<wait>a<wait>a"]
    boot_wait = "1s"
    # Add files to an ISO and mount it to the VM. 
    cd_files = [
        "./unattend/Autounattend.xml",
        "./unattend/sysprep_unattend.xml",
        "./scripts"
        ]
    # Guest additions are installed with Chocolatey
    guest_additions_mode = "disable" 
    communicator = "winrm"
    winrm_username = "${var.username}"
    winrm_password = "${var.password}"
    winrm_use_ntlm = true
    winrm_timeout = "6h"
    disable_shutdown = true
    shutdown_timeout = "1h"
}

build {
    name = "Win10Install"
    sources = ["virtualbox-iso.Win10Pro"]

    provisioner "windows-update" {
        # Run Windows updates. This will reboot the machine automatically
    }
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
        script = "./scripts/InstallApps.ps1"
    }

    # Add more provisioners here to run additional scripts...

    provisioner "windows-shell" {
        # The final provisioner to run sysprep. Do not add more provisioners after this one!
        # Once this provisioner runs, packer will wait up to 1 hour for the machine to shutdown before the build fails
        script = "./scripts/sysprep.bat"
        valid_exit_codes = ["0", "16001"]
    }

    post-processor "vagrant" {
        # Export VM to a .box for vagrant to use
        output = "${var.export_path}/packer_{{.BuildName}}_{{.Provider}}.box"
    }
}