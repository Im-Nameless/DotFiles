#!/bin/bash

# +++++ SETTING +++++
DISK=/dev/sda
USERNAME=noname
COUNTRY=Canada
SWAP_SIZE=4G
TIMEZONE=Canada/Eastern
KEYMAP=us
LOCALES=("en_UTF.UTF-8" "en_US ISO-8859-1")
EFI_ID=ArchGrub
# +++++ SETTING END +++++


# Reset the Disk
wipefs -a $DISK	# Make sure there is NOTHING on DISK
sgdisk -og $DISK # Recreate a GPT Table

# Create Partitions
sgdisk --new=1:0:500M --change-name=1:"Boot" --typecode=1:ef00 $DISK
sgdisk --new=2:0:+$SWAP_SIZE --change-name=2:"Swap" --typecode=2:8200 $DISK
sgdisk --new=3:0:0 --change-name=3:"Root" --typecode=3:8300 $DISK

# Create Filesystems
mkswap ${DISK}2
mkfs.ext4 ${DISK}3
mkfs.fat -F 32 ${DISK}1

# Mount the Disk
mount ${DISK}3 /mnt
mkdir /mnt/boot
mount ${DISK}1 /mnt/boot
swapon ${DISK}2

# Select Mirror-List
cp /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.bak
grep -E -A 1 ".*$COUNTRY.*$" /etc/pacman.d/mirrorlist.bak | sed '/--/d' > /etc/pacman.d/mirrorlist

# Install the base packages
pacstrap /mnt base

# User-Setup
echo "Enter Password for root"
arch-chroot /mnt passwd root

arch-chroot /mnt useradd -m -G wheel -s /bin/bash $USERNAME
echo "Enter Password for $USERNAME"
arch-chroot /mnt passwd $USERNAME

# Install additional packages
pacstrap /mnt base-devel grub efibootmgr sudo xorg xterm xorg-twm xorg-xinit i3-gaps pulseaudio pavucontrol rxvt-unicode ranger rofi nemo blender darktable zsh xdg-user-dirs wget w3m feh vim unzip unrar ttf-dejavu steam openvpn okular obs-studio networkmanager networkmanager-openvpn network-manager-applet neomutt neofetch mesa rtorrent krita inkscape imagemagick curl compton cmus audacity firefox qt4 vlc gimp libreoffice go git atom udiskie

# Generate FSTab
genfstab -U /mnt > /mnt/etc/fstab

# Set locale
arch-chroot /mnt ln -sf /usr/share/zoneinfo/$TIMEZONE /etc/localtime

echo "en_US.UTF-8" > /mnt/etc/locale.gen
for i in ${LOCALESi[@]}; do
	echo ${i} >> /mnt/etc/locale.gen
done
arch-chroot /mnt locale-gen

echo "KEYMAP=$KEYMAP" > /mnt/etc/vconsole.conf
echo "FONT=lat9w-16" >> /mnt/etc/vconsole.conf

# Initramfs
arch-chroot /mnt mkinitcpio -p linux

# Install Bootloader
arch-chroot /mnt grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=$EFI_ID --recheck --debug

arch-chroot /mnt grub-mkconfig -o /boot/grub/grub.cfg

# User-Setup
#echo "Enter Password for root"
#arch-chroot /mnt passwd root
#
#arch-chroot /mnt useradd -m -G wheel -s /bin/bash $USERNAME
#echo "Enter Password for $USERNAME"
#arch-chroot /mnt passwd $USERNAME

# Enter new User to the sudoers
echo "$USERNAME ALL=(ALL) ALL" >> /mnt/etc/sudoers

arch-chroot /mnt systemctl enable dhcpcd.service
