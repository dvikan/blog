{"title": "Glemt truecrypt passord"}

Jeg glemte truecrypt passordet mitt. Heldigvis har jeg ingenting viktig kryptert.
La oss sjekke ut `truecrack` som bruteforcer truecrypt passord. 

Jeg husker at den første delen av passordet var `1q2w3e4r` og at den neste 
delen var et ord som fins i den norske ordboka.

Først laster jeg ned en norsk ordliste.

Deretter genererer jeg en liste som inneholder alle mulige passord på
denne formen;

    $ for pw in `cat norwegian.txt `;do echo "1q2w3e4r$pw"; done > norwegian.tc.txt

Deretter installerte jeg [truecrack](https://code.google.com/p/truecrack/)

    $ ./configure --enable-cpu
    $ make

Deretter startet jeg bruteforcingen:

    $ ./truecrack -t files.tc -w norwegian.tc.txt

Det tok 13 minutter å sjekke alle 61843 passordene med en hastighet på 79 
forsøk per sekund. Truecrack ga beskjed når den fant riktig passord.

