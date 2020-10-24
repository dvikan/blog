{"title": "Hvordan sjekke om Wordpress installasjon er hacket"}

## Undersøk nylig endrede filer

Se om det er noen mistenkelige endringer gjort de siste 10 dager

    find -mtime -10 -ls

Gitt at installasjonen ikke er oppdatert de siste 10 dager
er det mistenkelig med endrede filer. Sett bort ifra upload mappa.

## Søk etter php-filer i uploads mappa

Fordi uploads mappa typisk er skrivbar havner malware ofte her.

    find wp-content/uploads/ -iname  '*.php'

## Filintegritet

For å undersøke om noen av kjernefilene til wordpress-installasjonen er
blitt endret kan du sammenligne med en ren kopi.

    # Gå til installasjonsmappa
    cd /var/www/foo.com

    # Last ned wordpress
    git clone https://github.com/wordpress/wordpress cleancopy

    # Gå inn i mappa
    cd cleancopy

    # Sjekk ut samme versjon som er installert
    git checkout 4.9.1

    # Gå en mappe opp
    cd ..

    # Sammenlign alle filer
    diff -r wordpress/wp-admin/ cleancopy/wp-admin/
    diff -r wordpress/wp-includes/ cleancopy/wp-includes/
