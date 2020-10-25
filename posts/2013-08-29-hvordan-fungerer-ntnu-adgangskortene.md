{"title": "Hvordan fungerer NTNU adgangskortene"}

![ntnu kortet](/blogimages/ntnu-card-front.png)
![ntnu kortet](/blogimages/ntnu-card-back.png)

## Kortnummer og strekkode

Nummeret `460868` er kortnummeret og er knyttet til min 
ntnu-bruker på et vis. Mitt kort er fra høsten 2009.
Jeg tipper at dette er et tall som øker med én, for hvert nye kort
som produseres. Strekkoden inneholder det samme nummeret.

## Tall nede til venstre på bakside

Tallet nede til venstre er `14818476`. Tallet befinner seg både i
magnetstripe og på 125 KHz RFID-brikke.

## Magnetstripen

NTNU-kortet har en magnetstripe der magnetisert data er `573029000014818476`.
De siste åtte tallene er identisk med det trykte tallet ned til venstre på
baksiden. Prefix `573029` virker å være lik på alle kort.

## RFID brikkene

Kortet har to radiobrikker.

### EM4102 berøringfri teknologi (125 KHz)

Kort med 125 KHz teknologi som kun er lesbare har meget liten chip og er
rimelige, som også gjør kortet lite følsomt for brekkasje.
Dette emitter en id på ti tegn når den kommer i nærheten av en RFID-leser
som gir den strøm. Brikken er passiv og dens eneste funksjonalitet er å emitte
denne id-en.

Min 125 KHz Microsoft Windows USB RFID-leser rapporterer at id er `0004667445`.
Dersom `0004667445` omformes slik at hver 8-bits gruppe reverseres, får jeg
`14818476`! Altså befinner dette tallet seg tre steder:

* Fysisk påtrykt nede til venstre
* I magnetstripe
* I 125 KHz RFID brikke (med reverserte 8-bits grupper)

Linjeforeningen Delta har også funnet ut av dette og laget et 
[program som reverserer for deg](http://pi.deltahouse.no/card.php?n=4667445&magic=on).

### Mifare Classic 1k berøringsfri teknologi (13.56 MHz)

Dette er en Mifare Classic 1K brikke som også emitter en id på ti tegn.

Min id som emittes er `1917961176`. Denne id befinner seg også i ntnu 
sin LDAP server. Den kan slås opp med `ldapsearch -h at.ntnu.no -x uid=dageriv`.
Du må være på NTNU-nettverk for tilgang til tjenesten.

Mifare er en familie av brikker utviklet av Philips/NXP. Og Mifare Classic 
1K har 1024 bytes med lagringsplass. Brikken er fundamentalt en lagringsenhet på
1024 bytes.  Såvidt jeg har funnet ut brukes ikke lagringsplassen på Mifare brikken 
til noe.

[Les mer om mifare](https://en.wikipedia.org/wiki/MIFARE).

### NTNU og adgangskontroll

Dører bruker 125 KHz brikke id + fire siffer pin. Adgangssystemet til dører heter arx.

## Oppdatering 2014

![ntnu kortet](/blogimages/ntnu-card-front-2014.jpg)
![ntnu kortet](/blogimages/ntnu-card-back-2014.jpg)

Jeg fikk et nytt kort fordi mitt gamle sluttet å fungere.

Magnetstripa inneholder `573029000015920055`. Igjen ser vi at de 
siste åtte talla `15920055` også er trykt nede til venstre på baksiden.

Min MX5 RFID-leser viser at `6F004FD7ED` blir emitted. Jeg har ikke
125 khz leser tilgjengelig.
