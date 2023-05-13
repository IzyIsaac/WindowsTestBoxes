# Quickly create Windows 10 VMs for testing

## Install VirtualBox
1. https://www.virtualbox.org/wiki/Downloads

## Download a Windows ISO
Download a Windows 10 ISO with the [Windows Media Creation Tool](https://www.microsoft.com/en-us/software-download/windows10)

All testing was done with Windows 10 Pro, because that is what I use in production. Enterprise should also work. Home will probably require changes, but I have no idea why you would need a bunch of windows 10 home test boxes

## Download Packer
Install with chocolatey. This adds it your path automatically, but uses a community managed chocolatey package
```powershell
choco install packer
```

If you want to install straight from Hashicorp, [you can download a binary here](https://developer.hashicorp.com/packer/downloads)

[Then you need to add packer to your PATH](https://stackoverflow.com/questions/1618280/where-can-i-set-path-to-make-exe-on-windows)


## Create custom answer files
The main mechanism for automating a Windows install is by using an answer file called "Autounattend.xml". When the Windows install begins, it searches for Autounattend.xml in the installation ISO, as well as any removeable media connected to the computer. If it finds an Autounattend.xml, it using the settings defined within to automatically complete the installation. 

It also allows us to run commands upon first login. We can use this to setup WinRM, which packer can then use to finish building the image.

If you want to create your own custom answer file, you can use System Image Manager, which is part of the Windows ADK. There are many settings that can be configured, and the Microsoft documentation for those settings is a bit daunting to navigate. This article gives a decent rundown on how to create your own custom answer files: https://www.windowscentral.com/how-create-unattended-media-do-automated-installation-windows-10

I spent a great deal of time simplifying the answer files in this repository so they only contain what is required to build a Windows 10 image with Packer. There are no superfluous settings, and I have added comments for what each setting does. Hopefully this is helpful 

There are 2 unattend files in the repository. Autounattend.xml is used for the initial Windows install. It is responsible for installing Windows, skipping initial OOBE, and enabling WinRM for packer to use

sysprep_unattend.xml is much simpler, it just skips OOBE once the image is actually used to spin up a new VM. This file is given to sysprep, which then caches it in C:\Windows\Panther. When the sysprepped image is cloned and spun up as a new VM, OOBE chekcs this location, sees that there is an unattend.xml, and uses that to skip OOBE and autologin as vagrant user

## Add additional provisioning scripts
If you want to run some additional scripts during the image build, simply drop your script in the scripts folder and add a new "provisioner" block to the packer template and point it to your script

All scripts are also packaged into an ISO and mounted to the VM along with the unattend files so they can easily be manually ran while debugging a build

##