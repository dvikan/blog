{"title": "The smallest archlinux install guide (with full disk encryption)"}

[Download the archlinux iso](https://www.archlinux.org/download/)

    $ dd if=/dev/zero of=/dev/sdb bs=4M
    $ dd bs=4M if=/path/to/archlinux.iso of=/dev/sdb

    $ cfdisk /dev/sda
    $ mkfs.ext4 /dev/sda1
    $ cryptsetup --cipher aes-xts-plain64 --key-size 512 --hash sha512 --iter-time 5000 --use-random --verify-passphrase luksFormat /dev/sda2
    $ cryptsetup luksOpen /dev/sda2 root
    $ mkfs.ext4 /dev/mapper/root
    $ mount /dev/mapper/root /mnt
    $ mkdir /mnt/boot
    $ mount /dev/sda1 /mnt/boot
    $ pacstrap -i /mnt base
    $ genfstab -U -p /mnt >> /mnt/etc/fstab
    $ arch-chroot /mnt
    $ vi /etc/mkinitcpio.conf # add encrypt and shutdown hook to HOOKS. And dm_mod and ext4 to MODULES
    $ mkinitcpio -p linux
    $ pacman -S grub
    $ grub-install --recheck /dev/sda
    $ vi /etc/default/grub # GRUB_CMDLINE_LINUX="cryptdevice=/dev/sda2:root"
    $ grub-mkconfig -o /boot/grub/grub.cfg
    $ passwd # set root password
    $ exit
    $ umount /mnt/boot
    $ umount /mnt
    $ reboot

## Post-install setup

    $ useradd -m -g users -s /bin/bash dag
    $ passwd dag
    $ gpasswd -a dag wheel

## Other soon-needed stuff

    $ pacman -S sudo firefox ruby vim screen youtube-dl cmus rtorrent wgetpaste nmap lynx mutt msmtp tree offlineimap feh gnupg mplayer pkgfile evince alsa-plugins tcpdump dnsutils whois cups libcups ctags qemu pulseaudio newsbeuter clamav smartmontools ffmpeg base-devel xscreensaver nginx abs ntfs-3g php libreoffice git nfs-utils unzip net-tools markdown dosfstools gparted wpa_supplicant bitcoin-qt imagemagick netcat php-fpm odt2txt openvpn irssi antiword unrar abook iw openldap nodejs dos2unix rkhunter testdisk p7zip sshfs vnstat alsa-utils msmtp-mta strace macchanger hdparm wireshark-cli wireshark-gtk ncrack ispell
    $ visudo # Allow wheel group root access
    $ vim /etc/ssh/sshd_config # PermitRootLogin no

## X

    $ pacman -S xf86-video-ati xorg-twm xorg-xclock xterm xorg-xinit

## LXDE config

    $ pacman -S lxde
    $ mkdir -p ~/.config/openbox
    $ cp /etc/xdg/openbox/{menu.xml,rc.xml,autostart} ~/.config/openbox
    $ echo 'exec startlxde' >> ~/.xinitrc

