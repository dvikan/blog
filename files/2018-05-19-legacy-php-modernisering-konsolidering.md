{"title": "Legacy PHP modernisering - Konsolidering (del 2)"}

Nå som vi har en klasselaster kan vi fjerne alle include kall som kun laster
klasser og funksjoner inn i minnet.

## Konsolider klasser:

1. Finn en `include()` setning som laster inn en klassedefinisjon
2. Flytt fila til `src/` slik at den plukkes opp av autolasteren
3. Fjern alle linjer i kodebasen som inkluderer den klassedefinisjonen

For å finne alle linjer som inkluderer f.eks. `User.php` bruker vi regex:

    $ ack "^[ \t]*(include|include_once|require|require_once).*User\.php"

## Konsolider funksjoner

Autolasting fungerer kun med klasser. Legacy kodebaser har typisk en stor mengde
globale funksjoner som lastes inn med include.

Løsningen her er å flytte funksjoner inn i klasser og kalle på dem som 
statiske metoder på klassene.

Den generelle prosessen for å konsolidere funksjoner:

1. Finn en include setning som laster inn en funksjonsdefinisjon
2. Konverter fila til en klasse med funksjonen som statisk metode
3. Konverter alle funksjonskall til statisk metodekall 
4. Flytt klassefila til sentral klassemappe
5. Fjern alle linjer som inkluderer klassedefinisjonen

Her er et eksempel på en kandidat.

`Page.php:`

    <?php
    
    require 'utils/http.php';
    
    class Page  
    {   
        function render()
        {
            redirect('/home');     
        }
    }

`utils/http.php:`

    <?php
    
    function redirect($location)
    {
        header("Location: $location");
    }

Konverter til statisk metode:

`utils/http.php:`

    <?php
    
    class Http
    {
        public static function redirect($location)
        {
            header("Location: $location");
        }
    }

Konverter til metodekall:

`Page.php:`

    <?php
    
    require 'utils/http.php';
    
    class Page
    {
        function render()
        {
            Http::redirect('/home');
        }
    }

Flytt klassefila til sentral klassemappa:

    $ mv utils/http.php classes/Http.php

Fjern opprinnelig include setning:

`Page.php:`

    <?php
    
    class Page
    {
        function render()
        {
            Http::redirect('/home');
        }
    }
    
For å finne alle kall til redirect kan vi bruke regex:

    $ ack "header\s*\("


