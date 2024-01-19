#!/bin/bash
# uncomment to view debugging information
#set -xeuo pipefail

#check if we're root
if [[ "$UID" -ne 0 ]]; then
    echo "This script needs to be run as root!" >&2
    exit 3
fi

### Config options
target="/dev/vda"
efipart="/dev/vda1"
swappart="/dev/vda2"
rootpart="/dev/vda3"
rootmnt="/mnt"
locale="en_US.UTF-8"
keymap="us"
timezone="America/New_York"
hostname="arch"
username="jc"
#SHA512 hash of password. To generate, run 'mkpasswd -m sha-512', don't forget to prefix any $ symbols with \ . The entry below is the hash of 'password'
#user_password="\$6\$/VBa6GuBiFiBmi6Q\$yNALrCViVtDDNjyGBsDG7IbnNR0Y/Tda5Uz8ToyxXXpw86XuCVAlhXlIvzy1M8O.DWFB6TRCia0hMuAJiXOZy/"
user_password="\$6\$KMjCZajVhYXNihUr\$AfqyGDmloZs.sEWUkdsmpbKoZqEks3tbJS5Xr9goUCoXXJa71hDtbL3ZTXxhfc34QOOJpounnO9peYoWhRQCy1"


### Packages to pacstrap ##
pacstrappacs=(
        base
        base-devel
        efibootmgr
        grub
        git
        linux
        linux-firmware
        networkmanager
        neovim
        sudo
        terminus-font
        )
### Desktop packages #####
guipacs=(
        gnome
        gnome-tweaks
        gdm
        # plasma
        # plasma-wayland-session
        # sddm
        kitty
        firefox
        # alacritty
        # nm-connection-editor
        # neofetch
        # sbctl
        )

# Partition
echo "Creating partitions..."
sgdisk -Z "$target"
sgdisk \
    -n1:0:+512M  -t1:ef00 -c1:EFISYSTEM \
    -n2::+2G     -t2:8400 -c2:swap \
    -N3          -t3:8304 -c3:linux \
    "$target"
# Reload partition table
sleep 2
partprobe -s "$target"
sleep 2

echo "Making File Systems..."
# Create file systems
mkfs.vfat -F32 -n EFISYSTEM /dev/disk/by-partlabel/EFISYSTEM
mkfs.ext4 -F -L linux "$rootpart"
mkswap "$swappart"

# mount the root, and create + mount the EFI directory
echo "Mounting File Systems..."
mount "$rootpart" "$rootmnt"
mkdir "$rootmnt"/boot/efi -p
mount -t vfat /dev/disk/by-partlabel/EFISYSTEM "$rootmnt"/boot/efi
sleep 2

# mount & activating swap partition
echo "Activating SWAP partition"

swapon "$swappart"
sleep 2

#Update pacman mirrors and then pacstrap base install
echo "Pacstrapping..."
pacstrap -K $rootmnt "${pacstrappacs[@]}"
sleep 2

echo "Generating fstab file..."
genfstab -U $rootmnt >> "$rootmnt"/etc/fstab
sleep 2

echo "Setting up environment..."
#set up locale/env

#add our locale to locale.gen
sed -i -e "/^#"$locale"/s/^#//" "$rootmnt"/etc/locale.gen

#remove any existing config files that may have been pacstrapped, systemd-firstboot will then regenerate them
rm "$rootmnt"/etc/{machine-id,localtime,hostname,shadow,locale.conf} ||
systemd-firstboot --root "$rootmnt" \
	--keymap="$keymap" --locale="$locale" \
	--locale-messages="$locale" --timezone="$timezone" \
	--hostname="$hostname" --setup-machine-id \
	--welcome=false

#add terminus font to console
sed -i '/^KEYMAP/a\FONT=ter-124b' "$rootmnt"/etc/vconsole.conf
arch-chroot "$rootmnt" locale-gen
echo "Configuring for first boot..."

#add the local user
arch-chroot "$rootmnt" useradd -G wheel -m -p "$user_password" "$username"
#uncomment the wheel group in the sudoers file
sed -i -e '/^# %wheel ALL=(ALL:ALL) NOPASSWD: ALL/s/^# //' "$rootmnt"/etc/sudoers

#install the gui packages
echo "Installing GUI..."
arch-chroot "$rootmnt" pacman -Sy "${guipacs[@]}" --noconfirm --quiet

#enable the services we will need on start up
echo "Enabling services..."
systemctl --root "$rootmnt" enable NetworkManager gdm

echo "Generating  initial ramdisk..."
#generating initial ramdisk
arch-chroot "$rootmnt" mkinitcpio -p linux

echo "Installing the GRUB bootloader..."
#install the GRUB bootloader
arch-chroot "$rootmnt" grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=GRUB "$rootpart"

echo "Generating grub.cfg..."
#generated grub.cfg
arch-chroot "$rootmnt" grub-mkconfig -o /boot/grub/grub.cfg

#lock the root account
arch-chroot "$rootmnt" usermod -L root
#and we're done

echo "-----------------------------------"
echo "- Install complete. Rebooting.... -"
echo "-----------------------------------"
sleep 10
sync
# reboot
