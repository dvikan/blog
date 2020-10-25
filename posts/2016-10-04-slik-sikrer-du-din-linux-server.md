{"title": "Slik sikrer du din Linux-server"}

![Penguin](/blogimages/penguin.png)

Du vil unngå at din Linux-server blir brutt inn i.

For å redusere risikoen for innbrudd er det
en rekke grep du kan ta.

Du må gjøre en selvstendig vurdering av hvor
mye du vil redusere risikoen. Risikoredusering har en kostnad.

Jeg tar utgangspunktet i en ny Debian 8 installasjon på
et privat nettverk.

## SSH

SSH er en protokoll for administrering av maskiner over nettverk.
Åpne konfigurasjonsfila `/etc/ssh/sshd_config` og tillat kun nøkkel-autentisering:

    PermitRootLogin no
    PasswordAuthentication no

Restart SSH-tjeneste:

    $ systemctl restart ssh

## Unattended Upgrades

[Unattended Upgrades](https://wiki.debian.org/UnattendedUpgrades)
er en tjeneste for automatisk oppgradering av pakker.

Kommer det plutselig en ny sårbarhet i ssh eller nginx bør det
patches straks.

    $ apt-get install unattended-upgrades apt-listchanges
    $ dpkg-reconfigure -plow unattended-upgrades

## Brannmur

Hensikten med en brannmur er å filtrere nettverktrafikk.

Linux har en innebygd brannmur og vi skal bruke
[Uncomplicated Firewall (ufw)](https://wiki.debian.org/Uncomplicated%20Firewall%20(ufw)) for å konfigurere den.

    $ apt-get install ufw
    $ ufw default deny incoming
    $ ufw default allow outgoing
    $ ufw allow ssh
    $ ufw enable

## Malware deteksjon med rkhunter

Hvis det mot formodning skulle havne malware på serveren er det kjekt å få
beskjed om det på epost (antar lokalt epost oppsett). Rkhunter støtter også filintegritetssjekk.

    $ apt-get install rkhunter
    $ rkhunter --update # Get latest malware signatures
    $ rkhunter --propupd # Baseline file integrity
    $ rkhunter -c --enable all --disable none

Selv på en ny Debian-installasjon gir rkhunter advarsler. Dette må hvitelistes.
Hvitelisting kan stappes inn i `/etc/rkhunter.conf.local`:

    MAIL-ON-WARNING="root@localhost"
    ALLOWPROCLISTEN=/sbin/dhclient
    ALLOWDEVFILE=/dev/shm/pulse-shm-*
    ALLOWHIDDENDIR=/etc/.java

Etter litt hvitelisting kan du forsøke igjen med:

    rkhunter -c --enable all --disable none --rwo

Sett opp en cronjob som rkhunter kjører hver natt kl 04:15:

    crontab -e
    15 04 * * * /usr/bin/rkhunter --cronjob --update --quiet

## Overvåkning

[UptimeRobot](http://uptimerobot.com/)
er en tjeneste som pinger maskiner og gir beskjed dersom det ikke
ponges tilbake. Anbefales.

