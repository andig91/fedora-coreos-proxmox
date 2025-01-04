fedora-coreos-proxmox
===

## About
This is a fork from https://git.geco-it.net/GECO-IT-PUBLIC/fedora-coreos-proxmox.git, it has the modified as below:
- Fixed: the problem of `geco-motd` and `qemu-ga` during the setup of latest FCOS, according to this [post](https://forum.proxmox.com/threads/howto-wrapper-script-to-use-fedora-coreos-ignition-with-proxmox-cloud-init-system-for-docker-workloads.86494/post-463507)
- Feature: additional custom config of Template VM base on the modifies of [Doc-Tiebeau/proxmox-flatcar](https://github.com/Doc-Tiebeau/proxmox-flatcar)
- Feature: allow adding custom packages repo

## How To

1.  Be sure to install `git` on your PVE server first:

    ```shell
    apt update
    apt install git
    ```

2.  Clone this repository on your Proxmox server:

    ```shell
    git clone https://github.com/andig91/fedora-coreos-proxmox.git
    ```

3.  Get into the directory `fedora-coreos-proxmox`

    ```shell
    cd fedora-coreos-proxmox
    ```

4.  Modify `template_deploy.conf` to custom your VM parameter as below:

    ```
	# Only create a machine without template, the TEMPLATE_NAME will be the hostname (without modifications additional Version-Tag)
	SKIP_TEMPLATE="true"
	
	# template vm vars
	TEMPLATE_NAME="podman-fcos-test" # Template VM name append with <flactar_version> in Proxmox GUI
	TEMPLATE_RECREATE="false" # Fore recreate template ?
	# Note: If you want only update hook script and Template_Ignition file, you can keep it as false, these files are always overwritten
	TEMPLATE_VMID="341" # VMID of Template VM
	TEMPLATE_VMSTORAGE="local-lvm" # Target storage for template VM
	SNIPPET_STORAGE="local" # Target storage for snippets files
	VMDISK_OPTIONS=",discard=on"
	
	TEMPLATE_MEMORY="3072" # Amount of RAM for the template VM in MB
	TEMPLATE_CPU_TYPE="host" # Emulated CPU type
	TEMPLATE_CPU_CORE="2" # The number of cores for template VM
	# 0-False, 1-True
	TEMPLATE_AUTOSTART="1" # Whether the VM will be automatic restart after crash
	TEMPLATE_ONBOOT="0" # Whether the VM will be started during system bootup.
	
	
	TEMPLATE_IGNITION="fcos-base-tmplt.yaml"
	
	# fcos image version
	# The script vmsetup.sh set to "stable" if not set here. Alternatives: "testing" and "next"
	#STREAMS=stable # The stream you decide to use
	# The script vmsetup.sh get the latest version of your stream. Only set, if you want another version set it here
	#VERSION=41.20241122.3.0 # You need to bump it to latest version manually
	PLATEFORM=qemu
	BASEURL=https://builds.coreos.fedoraproject.org
	
	#Custom Cloud-Init
	# Active if you want to set it here
	#CIUSERNAME=betteradmin
	#CISSHKEY=./ed25519_fedoraCoreOS_inex.pub
    ```

5.  Add your custom packages repo in `hook-fcos.sh` as below:

    ```shell
    (...)

        echo -n "Fedora CoreOS: Adding custom packages repos..."
        pkgs_repo=(
            # Put the URL of custom packages repo here
            "https://pkgs.tailscale.com/stable/fedora/tailscale.repo"
            "https://download.docker.com/linux/fedora/docker-ce.repo"
        )
        
    (...)
    ```

6.  Run the scripts to generate the template VM:

    ```shell
    ./vmsetup.sh
    ```

7.  Check the template VM just generated in Proxmox Web GUI and clone a VM base on it.


8.  BEFORE first boot: update Cloud-Init config of your new VM in Proxmox Web GUI.
    > Without specifying, the default username is `admin`  
    > Some things could be done with the `template_deploy.conf`  

9.  Wait for multiple reboot the enjoy.


## Purge/Cleanup VM  

I was new to FCOS and butane, so many errors happen.  
Many errors I didn't see, because somewhere was old files mixed with a fresh install.  
So I created `vmpurge.sh`, to eliminate the VM including all cloud-init and ignition-files.  
You can run both scripts combined `./vmpurge.sh && ./vmsetup.sh`.  
The flag `TEMPLATE_RECREATE` doesn't remove the files in `/etc/pve/geco-pve/coreos/`. (and I don't want to extend the base-script)  

## Credits & Forks  

- Forked from awesome [Geco-It fedora-coreos-proxmox](https://git.geco-it.net/GECO-IT-PUBLIC/fedora-coreos-proxmox) Source [GPL V3]
- Forked from awesome [jimlee2048 fedora-coreos-proxmox](https://github.com/jimlee2048/fedora-coreos-proxmox) Source [GPL V3]
- [Doc-Tiebeau/proxmox-flatcar](https://github.com/Doc-Tiebeau/proxmox-flatcar)
- [Proxmox VE - Fedora CoreOS : Un mariage presque parfait / An almost perfect Union [Geco-iT Wiki]](https://wiki.geco-it.net/public:pve_fcos)
- [[TUTORIAL] - HOWTO : Wrapper Script to Use Fedora CoreOS Ignition with Proxmox cloud-init system for Docker workloads | Proxmox Support Forum](https://forum.proxmox.com/threads/howto-wrapper-script-to-use-fedora-coreos-ignition-with-proxmox-cloud-init-system-for-docker-workloads.86494)