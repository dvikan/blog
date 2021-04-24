{"title": "Legacy PHP modernisering - Erstatt global med Dependency Injection (del 3)"}

Det er veldig sannsynlig at en legacy-applikasjon har mange `global` variabler:

    <?php
    
    // Globalt skop
    $config = [
        'displayErrors' => false
    ];
    
    class Example
    {
        function giveExample()
        {
            global $config;
    
            if($config['displayErrors']) {
                // [...]
            }
        }
    }

Nøkkelordet `global` henter variabeler fra det globale skopet. En alternativ måte er å bruke `$GLOBALS['config']`.

Hvorfor er globale variabler et problem?

* Det er vanskelig å se klassens avhengigheter fra utsiden
* Endringer i variabelen påvirker alle andre steder som bruker den
* Gjør koden ufleksibel når forskjellige globale verdier trengs
* Vanskeliggjør testing

For å fjerne globale variabler kan vi starte med å flytte variabelen til en klassevariabel:

    <?php
    
    class Example
    {
        private $config;
    
        function __construct()
        {
            global $config;
    
            $this->config = $config;
        }
    
        function giveExample()
        {
            if($this->config['displayErrors']) {
                // [...]
            }
        }
    }

`$GLOBALS` kan bli erstattet på samme måte.

Neste steg er å bruke dependency injection. Det betyr at vi stapper inn $config fra utsiden:

    <?php
    
    $config = [
        'displayErrors' => false
    ];
    
    class Example
    {
        private $config;
    
        function __construct(array $config)
        {
            $this->config = $config;
        }
    
        function giveExample()
        {
            if($this->config['displayErrors']) {
                // [...]
            }
        }
    }
    
    $example = new Example($config);
    $example->giveExample();

Nå som vi har endret signaturen på konstruktøren er koden brekt mange steder i kodebasen. Derfor må vi finne
alle instansieringer i hele kodebasen og injecte `$config`. Bruk din IDE eller denne regexen:

    $ ack 'new\s+Example\W'

I PHP 5.3 kan klasser gis et alias:

    <?php

    use Example as Foo;

Hvis klassen har alias kan du finne alle alias slik:

    $ ack 'use\s+Example\s+as'

Hvis klasser instansieres med en variabel:

    <?php

    $class = $type . '_Record';
    $record = new $class;

må vi søke etter disse:

    $ ack 'new\s+\$'

og oppdatere dem manuelt.

## Super globals

[Superglobals](http://php.net/manual/en/language.variables.superglobals.php)
er automatisk global i alle skop. 

Det gjelder disse:

* $GLOBALS
* $_SERVER
* $_GET
* $_POST
* $_FILES
* $_COOKIE
* $_SESSION
* $_REQUEST
* $_ENV

Hvis kun en av disse er i bruk i en klasse kan vi injecte en kopi:

    <?php

    $example = new Example($_SERVER);
    
    // eller

    $example = new Example($_SERVER['REQUEST_METHOD']);

Vanligvis er flere i bruk samtidig. Vi kan ikke kopiere `$_SESSION` fordi det er en global referanse.

En løsning er å introdusere et `Request` objekt som innkapsler alle bortsett fra `$_SESSION`.
