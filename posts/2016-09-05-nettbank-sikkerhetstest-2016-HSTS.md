{"title": "Nettbank sikkerhetstest 2016 (HSTS)"}

![Rusty padlock]({{ site.url }}/blogimages/padlock.jpg)

Formålet med denne testen er å undersøke hvilke nettbanker som
benytter seg av sikkerhetsmekanismen
[HTTP Strict Transport Security](https://en.wikipedia.org/wiki/HTTP_Strict_Transport_Security) (HSTS).

HSTS er en mekanisme der webservere kan instruere nettlesere om at websidene
kun skal aksesseres over TLS.

Dette for å forhindre SSL-stripping angrep, der broen fra ikke-TLS til TLS angripes.

Datagrunnlaget av banker kommer fra Wikipedia-siden
[Liste over banker i Norge](https://no.wikipedia.org/wiki/Liste_over_banker_i_Norge).

Fra lista plukka jeg alle forretningsbanker med konsensjon
per. 10. februar 2015. Og de 17 sparebankenemed mest forvaltningskapital.

## To overraskelser!

Jeg gjorde et Google-søk på alle banknavn i et Chrome incognito-vindu.

Banker med TLS har Adwords-kampanjer med TLS-lenker.

Alle Google-resultater er oppført
med TLS-lenker til bankenes websider, bortsett fra to banker:

* [Netfonds Bank ASA](https://www.netfonds.no)
* [Nordea Bank Norge ASA](https://nettbanken.nordea.no/login/) (!)

*Update 2018: Netfonds har fortsatt ikke TLS-lenke. Nordea har nå TLS-lenke.*

Begge nettbanker leverer TLS-lenker først når kunder skal logge inn.

*Update 2018: Begge bankene har nå TLS over hele websiden.*

Ingen benytter seg av HSTS.

Målrettede angrep mot Netfonds- og Nordea-kunder
vil være relativt enkelt å utføre med lokal nettverk-tilgang.

## Resultater

Testen er utført 28. august 2016.

Av 34 banker er det 17 som **ikke** bruker HSTS:

* [BN Bank ASA](https://www.bnbank.no/)
* [Gjensidige Bank ASA](https://www.gjensidige.no/privat/bank)
* [KLP Banken AS](https://www.klp.no/person/bank)
* [Komplett Bank ASA](https://www.komplettbank.no/)
* [Landkreditt Bank AS](https://www.landkredittbank.no/)
* [Netfonds Bank ASA](https://www.netfonds.no)
* [Nordea Bank Norge ASA](https://nettbanken.nordea.no/login/)
* [OBOS-banken ASA](https://bank.obos.no/)
* [Pareto Bank ASA](https://paretobank.no/)
* [Santander Consumer Bank AS](https://www.santanderonline.no/)
* [Easybank](https://easybank.no/)
* [yA Bank AS](https://ya.no/)
* [Sparebanken Møre](https://www.sbm.no/)
* [Sparebanken Øst](https://www.oest.no/)
* [Sparebanken Sør](https://www.sor.no/)
* [Sparebanken Sogn og Fjordane](https://www.ssf.no/)
* [Helgeland Sparebank](https://www.hsb.no/)

Halvparten av bankene bruker ikke HSTS.

### Update mai 2018

Av 34 banker er det 14 som fortsatt **ikke** bruker HSTS:

* Bank2 ASA
* BN Bank ASA
* Eika Kredittbank AS
* Gjensidige Bank ASA
* Netfonds Bank ASA
* OBOS-banken ASA
* Pareto Bank ASA
* Santander Consumer Bank AS
* Easybank
* yA Bank AS
* Sparebanken Øst
* Sparebanken Sogn og Fjordane
* Helgeland Sparebank
* Fana Sparebank

Banker som har skrudd på HSTS siden sist:

* KLP Banken AS
* Komplett Bank ASA
* Landkreditt Bank AS
* Nordea Bank Norge ASA
* Sparebanken Møre
* Sparebanken Sør
 
Nykommere på lista som ser ut til å ha skrudd av HSTS er:

* Bank2
* Eika Kredittbank
* Fana Sparebank.

## Nettbanker burde skru på HSTS

I et SSL-stripping angrep
blir HTTPS-lenker omformet til HTTP-lenker. En angriper videresender
ut mot den ekte nettbanken og leverer HTTP-svaret til offeret.

Ofre vil ane ingen fare med mindre de registrerer at TLS-padlocken mangler
i nettleserens URL-felt.

## Kuriositeter

Nesten alle bankene har en `max-age=31536000` som er 365 dager.

`max-age` angir i antall sekunder hvor lenge nettlesere skal følge
HSTS.

Kun [BN Bank ASA](https://www.bnbank.no/) har en lavere `max-age` på
2592000 som er 30 dager.

Fire av bankene har en `max-age=-12221117`. Faktisk er alle `max-age`
forskjellig men de er bare 3-7 sekunder forskjellig.

RFC6797 sier at nettleseren
skal forkaste den når den ikke passer til den definerte grammatikken.

Disse fire bankene har feilkonfigurert `max-age` til å være negativ:

* [Bank2 ASA](https://bank2.no/)
* [Voss Veksel- og Landmandsbank ASA](https://vekselbanken.no/)
* [Sandnes Sparebank](https://sandnes-sparebank.no/)
* [Totens Sparebank](https://totenbanken.no/)

Etter å ha gjort et nytt søk viser det seg at disse max-agene går lavere
og lavere for hvert sekund som går.

Fire DNS-oppslag viser at alle domenene resolver til IP-adressen `94.246.120.87`
som eies av Eika Gruppen (tidligere Terra-gruppen AS).

## Reproduksjon

Last ned programvare:

* [PHP](http://php.net/downloads.php)
* [Composer](https://getcomposer.org/) (Dependency Manager for PHP)
* [https://github.com/dvikan/nettbank-sikkerhets-test-2016](https://github.com/dvikan/nettbank-sikkerhets-test-2016)

Eksekver:

    $ php composer.phar install
    $ php checkHSTS.php

## Epilog

Chrome har en innebygd forhåndslastet liste med domener som skal følge HSTS.
Ingen av nettbankene i denne testen er forhåndslastet med unntak av
[Monobank](https://monobank.no/).
