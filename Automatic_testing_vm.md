# TestBoxes

A collection of Packer templates and Vagrant environments for testing/learning/development. Virtual machines are a great way to test things without breaking your actual computers or ruining your customer environments. 

I would always keep a couple Windows 10 VMs available on all my computers to quickly test things out, and then rollback to a fresh snapshot after I was done. This began to get frustrating when testing certain things, such as Intune/Autopilot. Simply rolling back a snapshot is sometimes not an option, and a whole new VM needs to be created. I wanted to be able to do this with less friction, and be able to replicate it on ANY of my computers without tons of manual configuration. Simply clone the repo, build the box with packer if required, and spin it up with vagrant 
## What do I use this for?
* Quickly spin up a Windows 10 VM to test Intune/Autopilot

* Create an Active Directory lab for learning/testing automation

* Quickly spin up a Kali Linux box for HTB/TryHackMe

Every file has comments to explain what is going on to hopefully make this easier to copy/customize to fit other use cases

This project assumes your host is a Windows 10 machine, but it should work on other platforms since virtualbox is used as the provider

## Prerequisites
* [VirtualBox](https://www.virtualbox.org/wiki/Downloads)


* Hashicorp Packer 
    Install with chocolatey. This adds it your path automatically, but uses a community managed chocolatey package
    ```powershell
    choco install packer
    ```
    If you want to install Packer straight from Hashicorp, [you can download a binary here](https://developer.hashicorp.com/packer/downloads). Make sure to add it to your path

* Install [Vagrant](https://developer.hashicorp.com/vagrant/downloads)

* Install an ISO creation tool that packer can use: xorriso, mkisofs, hdiutil, oscdimg. oscdimg is included in the [Windows ADK](https://learn.microsoft.com/en-us/windows-hardware/get-started/adk-install). Just install "Deployment Tools" during setup, and add C:\Program Files (x86)\Windows Kits\10\Assessment and Deployment Kit\Deployment Tools\amd64\Oscdimg to your PATH

## Project structure
Each top level folder contains everything required to spin up a vagrant environment

### Window10
Basic Windows 10 Pro box
* Chocolatey
* Chrome
* 7zip
* VBox guest additions
* Windows updated during packer build
* TPM + Secure Boot enabled
How to use this box:
1. Ensure you have a Windows 10 ISO downloaded from the [Windows Media Creation Tool](https://www.microsoft.com/en-us/software-download/windows10)
2. Edit build.ps1
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
