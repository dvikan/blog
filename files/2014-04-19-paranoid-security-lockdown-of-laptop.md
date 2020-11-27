{"title": "Paranoid security lockdown of laptop"}

What I want to achieve is:

* Minimize damage done if laptop is stolen
* Minimize damage done if laptop is tampered with while away from it
* Minimize chance of being compromised while system is running
* Maximize chance of detection if system is compromised
* Maximize anonymity on the internet

Security is a tradeoff. Having a more secure system has costs.
This text is for those willing to incur some costs in order to be more secure.

## SSH server

Only allow your own user to login. Disable password authentication and 
force public key authentication.

In `/etc/ssh/sshd_config` you should add:

    AllowUsers <username> (remove <>)
    PasswordAuthentication no
    PermitRootLogin no

## Full disk encryption

Disk encryption ensures that files are always stored on disk in an encrypted 
form. The files only become available to the operating system and applications
in readable form while the system is running and unlocked by a trusted user. 
An unauthorized person looking at the disk contents directly, will only find
garbled random-looking data instead of the actual files.

For example, this can prevent unauthorized viewing of the data when the computer or hard-disk is:

* Located in a place to which non-trusted people might gain access while you're away
* Lost or stolen, as with laptops, netbooks or external storage devices
* In the repair shop
* Discarded after its end-of-life

In addition, disk encryption can also be used to add some security 
against unauthorized attempts to tamper with your operating system. For example, the installation of keyloggers or Trojan horses by attackers who can gain physical access to the system while you're away. 

### Preparation

Fill drive with random data to prevent recovery of previously
stored data. It also prevents detection of usage patterns on drive.

    $ dd if=/dev/random of=/dev/sda bs=1M

### Full disk encryption using dmcrypt + LUKS

    $ cryptsetup --cipher aes-xts-plain64 --key-size 512 --hash sha512 --iter-time 5000 --use-random --verify-passphrase luksFormat /dev/sda2
    $ cryptsetup luksOpen /dev/sda2 root
    $ mkfs.ext4 /dev/mapper/root
    $ mount /dev/mapper/root /mnt
    $ mkdir /mnt/boot
    $ mount /dev/sda1 /mnt/boot

Edit `/etc/mkinitcpio.conf` and add `encrypt` and `shutdown` hook to HOOKS.  Place
the `encrypt` hook directly before filesystem hook.
And `dm_mod` and `ext4` to MODULES.

Edit `/etc/default/grub` and add `GRUB_CMDLINE_LINUX="cryptdevice=/dev/sda2:root"`

### Swap space

No. Buy enough RAM.

## BIOS

Set a BIOS password. This prevents cold boot attacks where RAM is immediately 
dumped after a reboot. It has been shown that data in RAM persists for a few
seconds after downpowering.

## USB attacks

When a USB device is inserted, the USB driver in kernel is invoked. If a bug
is discovered here it may lead to code running:

    $ system("killall gnome-screensaver")

Or it may slurp up all the memory and cause the linux out-of-memory-killer 
to kill the screensaver process. 

USB driver load can be disabled in BIOS. Or you can:

    $ echo 'install usb-storage : ' >> /etc/modprobe.conf 

## USB automounting attacks

Lesser beings willing to allow the USB driver to load should atleast
disable automounting. Allowing filesystems to automount causes even more potentially 
vulnerable code to run. E.g. Ubuntu once opened the file explorer and showed thumbnails
of images. One researcher was able to find a bug in one image library used to
produce thumbnail. He just inserted USB drive and the exploit killed the screensaver.

## Screensaver

Set a 
[screensaver](https://wiki.archlinux.org/index.php/Xscreensaver)
with password lock to kick in after one minute.
Create keyboard shortcut to lock screen and manually lock when temporarily
leaving system. Power down for longer absences.

## File integrity

To detect compromised files, file integrity tools can store hashsums
of them and let you know if they suddenly change. Obviously, malware
can also modify the hashsums. But it helps in cases where malware do not.
For the extra cautious, you could store the file integrity hashsums offline or
print them out.

### AIDE (Advanced intrusion detection environment)

    $ aide -i
    $ mv /var/lib/aide/aide.db.new.gz /var/lib/aide/aide.db.gz 
    $ aide -C

### rkhunter

Rootkit Hunter additionally scans system for rootkits.

On a clean system update the system properties

    $ rkhunter --propupd
    $ rkhunter --check --rwo -sk

There probably are a few false positives. Edit the `/etc/rkhunter.conf.local`
and add exceptions for them.

Here is my crontab for these two programs:

    MAILTO=me@dvikan.no
    MAILFROM=me@dvikan.no
    30 06 * * 1 /usr/bin/rkhunter --cronjob --rwo
    35 06 * * 1 /usr/bin/aide -C

### VPN

Use a trusted VPN to make ISP unable to see your traffic.

[www.ipredator.se](https://www.ipredator.se/)

To prevent traffic from accidentially flowing via real physical network
interface, you should only allow outgoing traffic to be UDP on port 1194.
Also for DNS and DHCP, port 53, 67, and 68 outgoing must be allowed.

### Simple stateful firewall

Drop everything in INPUT. Then allow already existing connections.
Also allow all to loopback interface.

    $ iptables -P INPUT DROP
    $ iptables -P FORWARD DROP
    $ iptables -P OUTPUT ACCEPT

    $ iptables -A INPUT -i lo -j ACCEPT
    $ iptables -A INPUT -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT
    $ iptables -A OUTPUT -o enp2s0 -p udp -m udp --dport 53 -j ACCEPT
    $ iptables -A OUTPUT -o enp2s0 -p udp -m udp --dport 1194 -j ACCEPT
    $ iptables -A OUTPUT -o tun0 -j ACCEPT
    $ iptables -A OUTPUT -o enp2s0 -p udp -m udp --dport 67:68 -j ACCEPT

Save rules into file and have it loaded on boot:

    $ iptables-save > /etc/iptables/iptables.rules
    $ systemctl enable iptables

If your VPN does not support ipv6, then drop all outgoing traffic on ipv6:

    $ ip6tables -P OUTPUT DROP

And add `ipv6.disable=1` to kernel line to prevent loading of ipv6 module.

### DNS

Do not use your ISP's DNS server. Unless you want them to see the domains you are
visiting.

[https://www.ipredator.se/page/services#service_dns](https://www.ipredator.se/page/services#service_dns)

Put this in `/etc/resolv.conf`

    nameserver 194.132.32.32
    nameserver 46.246.46.246

Preserve DNS settings by adding the following to `/etc/dhcpcd.conf`:

    nohook resolv.conf

### MAC address

To randomize MAC address and keep vendor prefix:

    $ macchanger -e interface

After boot, set a [random MAC address](https://wiki.archlinux.org/index.php/MAC_Address_Spoofing).

Here is an example systemd service which you put in
`/etc/systemd/system/macchanger@.service`.

    [Unit]
    Description=Macchanger service for %I
    Documentation=man:macchanger(1)
    
    [Service]
    ExecStart=/usr/bin/macchanger -e %I
    Type=oneshot
    
    [Install]
    WantedBy=multi-user.target

Then to enable it:

    systemctl enable macchanger@enp2s0

## Firefox

### Sandbox

Sandfox runs programs within sandboxes which limit the programs access to only
the files you specify. 
Why run Firefox and other programs in a sandbox? In the Firefox example, there 
are many components running: java, javascript, flash, and third-party plugins. All of 
these can open vulnerabilities due to bugs and malicious code; under certain 
circumstances these components can run anything on your computer and can
access, modify, and delete your files. It's nice to know that when such
vulnerabilities are exploited, these components can only see and access a 
limited subset of your files.

Create a sandbox with sandfox:

    $ sudo sandfox firefox

Do not install flash or java. Disable webrtc to prevent
[local IP discovery](http://net.ipcalf.com/).

For registration forms use a 
[pseudorandom](http://www.fakenamegenerator.com/gen-male-no-no.php) identity
and [throwaway](https://www.guerrillamail.com/) email address.

Make firefox prefer cipher suites providing forward secrecy.
### Extentions

[noscript](https://addons.mozilla.org/en-US/firefox/addon/noscript/)

[https everywhere](https://www.eff.org/https-everywhere)

## Email

Many SMTP and IMAP servers use TLS. Not all do. Email is decrypted at each
node. End-to-end encryption makes email secure. The most widely used standard
for encrypting files is the OpenPGP standard. 
[GnuPG](http://gnupg.org/index.html) is a free implementation of it.

A short usage summary is:

    $ gpg --gen-key # generate keypair
    $ gpg --detach-sign --armour file.txt # signature
    $ gpg -r 7A2B13CD --armour  --sign --encrypt file.txt # signature and encryption

## TLS gotchas

If not all HTTP content is served over TLS, an attacker could inject javascript
code which extracts your password. Or simply sniff the session cookie before or after.

The bridge between plaintext and TLS in HTTP is
a [weak point](http://www.thoughtcrime.org/software/sslstrip/). The HTTP HSTS
header mitigates this particular threat.

If not a ciphersuite with perfect forward security is used, then an attacker can
at a later point use the server's private key to decrypt historically captured traffic.

## Other stuff

Do not allow other users to read your files

    $ chmod 700 $HOME

Some people tend to use the recursive option (-R) indiscriminately which 
modifies all child folders and files, but this is not necessary, and may 
yield other undesirable results. The parent directory alone is sufficient 
for preventing unauthorized access to anything below the parent. 

Put tape over webcam.

## Other decent resources

[Surveillance Self-Defense](https://ssd.eff.org/)
