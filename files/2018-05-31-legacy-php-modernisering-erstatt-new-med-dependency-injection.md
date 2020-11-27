{"title": "Legacy PHP modernisering - Erstatt new med Dependency Injection (del 4)"}

new operatoren brukes til å instansiere objekter. Dependency Injection (DI) betyr at man stapper inn avhengigheter i konstruktør, klasse eller felt.

Her er et eksempel som ikke bruker Dependency Injection:

	<?php

	class Markdown
	{
		function compile($markdown)
		{
			$output = new File('output.html');

			$html = $this->compileMarkdown($markdown);

			$output->write($html);
		}

		function compileMarkdown($markdown)
		{
			// Kompileringskode...
			return '<h1>hello world</h1>';
		}
	}

	class File
	{
		private $filename;

		function __construct($filename)
		{
			$this->filename = $filename;
		}

		function write($data)
		{
			file_put_contents($this->filename, $data);
		}
	}

	$markdown = new Markdown;

	$markdown->compile('# hello world');

Her ser vi at new operatoren brukes inni Markdown klassen. Hvorfor er dette problematisk?

* Det er vanskeligere å se klassens avhengigheter fra utsiden
* Markdown og File er innvikla (tight coupling)
* Det er vanskeligere å konfigure Markdown (f.eks. skrive til STDOUT)
* Det er vanskeligere å teste

Poenget med Dependency Injection er å dytte inn avhengigheter fra utsiden.

Slik kan vi fjerne new fra Markdown:

	<?php

	class Markdown
	{
		private $file;

		function __construct(File $file)
		{
			$this->file = $file;
		}

		function compile($markdown)
		{
			$html = $this->compileMarkdown($markdown);

			$this->file->write($html);
		}

		function compileMarkdown($markdown)
		{
			// Kompileringskode...
			return '<h1>hello world</h1>';
		}
	}

	$output = new File('output.html');

	$markdown = new Markdown($output);

	$markdown->compile('# hello world');

Inndyttingen kalles Constructor Injection fordi den kommer inn via konstruktøren. Vi kunne også ha stappa den inn i metodekallet:

	<?php

	class Markdown
	{
		function compile($markdown, File $output)
		{
			$html = $this->compileMarkdown($markdown);

			$output->write($html);
		}

		function compileMarkdown($markdown)
		{
			// Kompileringskode...
			return '<h1>hello world</h1>';
		}
	}

	$output = new File('output.html');

	$markdown = new Markdown();

	$markdown->compile('# hello world', $output);

Fordi Markdown klassen nå er mindre innvikla med File er den mer konfigurerbar. Hvis vi vil skrive til STDOUT gjør vi bare slik:

	<?php

	$output = new File('php://STDOUT');

	$markdown = new Markdown();

	$markdown->compile('# hello world', $output);

Vi kan også enklere skrive enhetstester uten å berøre filsystemet:

	<?php

	class MarkdownTest extends PHPUnit\Framework\TestCase
	{
		function testCompile()
		{
			$file = $this->createMock(File::class);

			$file->expects($this->once())
				  ->method('write');

			$markdown = new Markdown($file);

			$markdown->compile('something');
		}

		function testCompileMarkdown()
		{
			$file = $this->createMock(File::class);

			$markdown = new Markdown($file);

			$actual = $markdown->compileMarkdown('# hello world');

			$this->assertEquals('<h1>hello world</h1>', $actual);
		}
	}

Kjør testene med phpunit:

	$ phpunit MarkdownTest.php 

	PHPUnit 7.1.5 by Sebastian Bergmann and contributors.

	..                                                                  2 / 2 (100%)

	Time: 44 ms, Memory: 4.00MB

	OK (2 tests, 2 assertions)

## Hva med Exceptions og andre innebygde PHP-klasser?

	<?php

	function detonate()
	{
		throw new LogicException('Not yet!');
	}

Exception klasser og visse andre innebygde PHP-klasser kan fint instansieres hvor som helst. Det er fordi de sjeldent endres. Til syvende og sist handler programmering om å vurdere sannsynligheten for framtidig endring.

Hvis koden din aldri skal leses eller endres kan du se bort fra rådene i dette blogginnlegget :)
## Hva med avhengigheter til avhengigheter?

Ikke stapp inn avhengigheter til avhengigheter. Opprett hele objektgrafen på utsiden.
## Blir ikke dette mye ekstra kode?

Jo det blir det. Gevinsten er krystallklar og mindre innvikla kode som er testbar!
## DI Container

Vi kan fint manuelt opprette objektgrafene. Men det blir mye duplisert kode. En Container kan hjelpe oss med dette.

Her er en naiv container:

	<?php

	class Container
	{
		function getStandardOutputMarkdown()
		{
			$file = new File('php://STDOUT');

			$markdown = new Markdown($file);

			return $markdown;
		}
	}

	$container = new Container;

	$markdown = $container->getStandardOutputMarkdown();

	$markdown->compile('# hello world');

Hvis vi ikke ønsker en ny instans hver gang Markdown hentes ut fra Containeren kan objektet deles slik:

	<?php

	class Container
	{
		static protected $shared = [];

		function getStandardOutputMarkdown()
		{
			if (isset(self::$shared['markdown'])) {
				return self::$shared['markdown'];
			}

			$file = new File('php://STDOUT');

			$markdown = new Markdown($file);

			return self::$shared['markdown'] = $markdown;
		}
	}

Trenger du en poplær og godt testet Container kan jeg anbefale Pimple.

