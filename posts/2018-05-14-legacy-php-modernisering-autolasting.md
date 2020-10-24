{"title": "Legacy PHP modernisering - Autolasting (del 1)"}

En simpel definisjon på legacy applikasjon er en applikasjon du
har arvet. Den ble skrevet før du kom dit.

Andre betydninger:

* Dårlig organisert
* Vanskelig å forstå
* Vanskelig å vedlikeholde
* Vanskelig å endre
* Fravær av tester 
* Utestbar

Legacy-applikasjoner er ofte include-basert. Det vil si at `include()` brukes for lasting av funksjoner/klasser og programflyt.

Andre kjennetegn:

* Globale variabler
* Script-filer plassert i rota av web server
* En svær `functions.php`
* Spesiell logikk i toppen av filer
* Få klasser
* Script-filene blander modell, visning og kontroll

En legacy-applikasjon bruker `include()` for å sette sammen
mange biter til en hel applikasjon.

Et eksempel på hva jeg snakker om fins i [bunnen av siden](#bunnen).

En total omskriving er fristende for utviklere men vanligvis uaktuelt.
Et alternativ er gradvis refaktorering (modernisering!).

## Forberedelser

Du må stappe applikasjonen inn i et versjoneringssystem
fordi du trenger full kontroll over endringer:

    $ mkdir legacy-001
    $ cp -r ~/Downloads/www/ legacy-001/
    $ cd legacy-001/
    $ git init
    Initialized empty Git repository in /home/foo/repos/legacy-001/.git/
    $ git add .
    $ git commit -m'Initial commit'

Deretter verifiser at du er kapabel til å installere applikasjonen i produksjon.

## Automatisk lasting av klasser 

Det første moderniseringssteget er å sette opp
[autolasting](http://php.net/manual/en/language.oop5.autoload.php).

Hensikten med autolasting er å unngå manuell inkludering av klasser.

Registrer autolaster med `spl_autoload_register()`:

    <?php

    spl_autoload_register(function($class) {
        $file = __DIR__.'/src/'.$class.'.php';

        require $file;
    });

Opprett `src/` mappe:

    $ mkdir src

For å bruke autolasteren i et script inkluderer du den:

    <?php

    require __DIR__.'/autoloader.php';

    $cookie = new Cookie;

Fra nå av skal klasser plasseres i `src/` mappa.

[Konsolidering (del 2)](/legacy-php-modernisering-konsolidering)

## <a name="bunnen"></a>Legacy eksempel

	<?php
	include("common/db_include.php");
	include("common/functions.inc");
	include("theme/leftnav.php");
	include("theme/header.php");
	
	define("SEARCHNUM", 10);
	
	function letter_links()
	{
	    global $p, $letter;
	    $lettersArray = array(
	        '0-9', 'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I',
	        'J', 'K', 'L', 'M', 'N', 'O', 'P', 'Q', 'R', 'S',
	        'T', 'U', 'V', 'W', 'X', 'Y', 'Z'
	    );
	    foreach ($lettersArray as $let) {
	        if ($letter == $let)
	            echo $let.' ';
	        else
	            echo '<a class="letters" '
	            . 'href="letter.php?p='
	            . $p
	            . '&letter='
	            . $let
	            . '">'
	            . $let
	            . '</a> ';
	    }
	}
	
	$page = ($page) ? $page : 0;
	
	if (!empty($p) && $p!="all" && $p!="none") {
	    $where = "`foo` LIKE '%$p%'";
	} else {
	    $where = "1";
	}
	
	if ($p=="hand") {
	
	    $where = "`foo` LIKE '%type1%'"
	        . " OR `foo` LIKE '%type2%'"
	        . " OR `foo` LIKE '%type3%'";
	
	}
	
	$where .= " AND `bar`='1'";
	if ($s) {
	    $s = str_replace(" ", "%", $s);
	    $s = str_replace("'", "", $s);
	    $s = str_replace(";", "", $s);
	    $where .= " AND (`baz` LIKE '%$s%')";
	    $orderby = "ORDER BY `baz` ASC";
	} elseif ($letter!="none" && $letter) {
	    $where .= " AND (`baz` LIKE '$letter%'"
	        . " OR `baz` LIKE 'The $letter%')";
	    $orderby = "ORDER BY `baz` ASC";
	} else {
	    $orderby = "ORDER BY `item_date` DESC";
	}
	$query = mysql_query(
	    "SELECT * FROM `items` WHERE $where $orderby
	    LIMIT $page,".SEARCHNUM;
	);
	$count = db_count("items", $where);
	?>
	
	<td align="middle" width="480" valign="top">
	<img border="0" width="480" height="30"
	src="http://example.com/images/example1.gif">
	<table border="0" cellspacing="0" width="480"
	cellpadding="0" bgcolor="#000000">
	<tr>
	<td colspan="2" width="480" height="50">
	<img border="0"
	src="http://example.com/images/example2.gif">
	</td>
	</tr>
	<tr>
	<td width="120" align="right" nowrap>
	<img border="0"
	src="http://example.com/images/example3.gif">
	</td>
	<td width="360" align="right" nowrap>
	<div class="letter"><?php letter_links(); ?></div>
	</td>
	</tr>
	</table>
	
	<form name="search" enctype="multipart/form-data"
	action="search.php" method="POST" margin="0"
	style="margin: 0px;">
	<table border="0" style="border-collapse: collapse"
	width="480" cellpadding="0">
	<tr>
	<td align="center" width="140">
	<input type="text" name="s" size="22"
	class="user_search" title="enter your search..."
	    value="<?php
	echo $s
	    ? $s
	    : "enter your search..."
	    ;
	?>" onFocus=" enable(this); "
	onBlur=" disable(this); ">
	</td>
	<td align="center" width="70">
	<input type="image" name="submit"
	src="http://example.com/images/user_search.gif"
	width="66" height="17">
	</td>
	<td align="right" width="135">
	<img border="0"
	src="http://example.com/images/list_foo.gif"
	width="120" height="26">
	</td>
	<td align="center" width="135">
	<select size="1" name="p" onChange="submit();">
	<?php
	if ($p) {
	    ${$p} = 'selected="selected"';
	}
	foreach ($foos as $key => $value) {
	    echo '<option value="'
	        . $key
	        . '" '
	        . ${$key}
	        . '>'
	        . $value
	        . '</option>';
	}
	
	?>
	</select>
	</td>
	</tr>
	</table>
	<?php if ($letter) {
	echo '<input type="hidden" name="letter" '
	    . 'value="' . $letter . '">';
	} ?>
	</form>
	
	<table border="0" cellspacing="0" width="480"
	cellpadding="0" style="border-style: solid; border-color:
	#606875; border-width: 1px 1px 0px 1px;">
	<tr>
	<td>
	<div class="nav"><?php
	    $pagecount = ceil(($count / SEARCHNUM));
	$currpage = ($page / SEARCHNUM) + 1;
	if ($pagecount)
	    echo ($page + 1)
	    . " to "
	    . min(($page + SEARCHNUM), $count)
	    . " of $count";
	?></div>
	</td>
	<td align="right">
	<div class="nav"><?php
	unset($getstring);
	if ($_POST) {
	    foreach ($_POST as $key => $val) {
	        if ($key != "page") {
	            $getstring .= "&$key=$val";
	        }
	    }
	}
	if ($_GET) {
	    foreach ($_GET as $key => $val) {
	        if ($key != "page") {
	            $getstring .= "&$key=$val";
	        }
	    }
	}
	
	if (!$pagecount) {
	
	    echo "No results found!";
	} else {
	    if ($page >= (3*SEARCHNUM)) {
	        $firstlink = " | <a class=\"searchresults\"
	            href=\"?page=0$getstring\">1</a>";
	        if ($page >= (4*SEARCHNUM)) {
	            $firstlink .= " ... ";
	        }
	    }
	
	    if ($page >= (2*SEARCHNUM)) {
	        $prevpages = " | <a class=\"searchresults\""
	            . " href=\"?page="
	            . ($page - (2*SEARCHNUM))
	            . "$getstring\">"
	            . ($currpage - 2)
	            ."</a>";
	    }
	
	    if ($page >= SEARCHNUM) {
	        $prevpages .= " | <a class=\"searchresults\""
	            . " href=\"?page="
	            . ($page - SEARCHNUM)
	            . "$getstring\">"
	            . ($currpage - 1)
	            . "</a>";
	    }
	
	    if ($page==0) {
	        $prevlink = "&laquo; Previous";
	    } else {
	        $prevnum = $page - SEARCHNUM;
	        $prevlink = "<a class=\"searchresults\""
	            . " href=\"?page=$prevnum$getstring\">"
	            . "&laquo; Previous</a>";
	    }
	
	    if ($currpage==$pagecount) {
	        $nextlink = "Next &raquo;";
	    } else {
	        $nextnum = $page + SEARCHNUM;
	        $nextlink = "<a class=\"searchresults\""
	            . " href=\"?page=$nextnum$getstring\">"
	            . "Next &raquo;</a>";
	    }
	
	    if ($page < (($pagecount - 1) * SEARCHNUM))
	        $nextpages = " | <a class=\"searchresults\""
	        . " href=\"?page="
	        . ($page + SEARCHNUM)
	        . "$getstring\">"
	        . ($currpage + 1)
	        . "</a>";
	
	    if ($page < (($pagecount - 2)*SEARCHNUM)) {
	        $nextpages .= " | <a class=\"searchresults\""
	            . " href=\"?page="
	            . ($page + (2*SEARCHNUM))
	            . "$getstring\">"
	            . ($currpage + 2)
	            . "</a>";
	    }
	    if ($page < (($pagecount - 3)*SEARCHNUM)) {
	        if ($page < (($pagecount - 4)*SEARCHNUM))
	            $lastlink = " ... of ";
	        else
	            $lastlink = " | ";
	        $lastlink .= "<a class=\"searchresults\""
	            . href=\"?page="
	            . (($pagecount - 1)*SEARCHNUM)
	            . "$getstring\">"
	            . $pagecount
	            . "</a>";
	    }
	
	    $pagenums = " | <b>$currpage</b>";
	    echo $prevlink
	        . $firstlink
	        . $prevpages
	        . $pagenums
	        . $nextpages
	        . $lastlink
	        . ' | '
	        . $nextlink;
	}
	?></div>
	</td>
	</tr>
	</table>
	
	<table border="0" cellspacing="0" width="100%"
	cellpadding="0" style="border-style: solid; border-color:
	#606875; border-width: 0px 1px 0px 1px;">
	
	<?php while($item = mysql_fetch_array($query)) {
	
	$links = get_links(
	    $item[id],
	    $item[filename],
	    $item[fileinfotext]
	);
	
	$dls = get_dls($item['id']);
	
	echo '
	<tr>
	<td class="bg'.(($ii % 2) ? 1 : 2).'" align="center">
	
	<div style="margin:10px">
	<table border="0" style="border-collapse:
	collapse" width="458" id="table5" cellpadding="0">
	<tr>
	<td rowspan="3" width="188">
	<table border="0" cellpadding="0"
	cellspacing="0" width="174">
	<tr>
	<td colspan="4">
	<img border="0"
	src="http://www.example.com/common/'
	.$item[thumbnail].'"
	width="178" height="74"
	class="media_img">
	</td>
	</tr>
	<tr>
	<td style="border-color: #565656;
	border-style: solid; border-width: 0px
	0px 1px 1px;" width="18">
	<a target="_blank"
	href="'.$links[0][link].'"
	'.$links[0][addlink].'>
	<img border="0"
	src="http://example.com/images/'
	.$links[0][type].'.gif"
	
	width="14" height="14"
	hspace="3" vspace="3">
	</a>
	</td>
	<td style="border-color: #565656;
	border-style: solid; border-width: 0px
	0px 1px 0px;" align="left" width="71">
	<a target="_blank"
	href="'.$links[0][link].'"
	class="media_download_link"
	'.$links[0][addlink].'>'
	.(round($links[0][filesize]
	/ 104858) / 10).' MB</a>
	</td>
	<td style="border-color: #565656;
	border-style: solid; border-width: 0px
	0px 1px 0px;" width="18">
	'.(($links[1][type]) ? '<a
	target="_blank"
	href="'.$links[1][link].'"
	'.$links[1][addlink].'><img
	border="0"
	src="http://example.com/images/'
	.$links[1][type].'.gif"
	width="14" height="14" hspace="3"
	vspace="3">
	</td>
	<td style="border-color: #565656;
	border-style: solid; border-width: 0px
	1px 1px 0px;" align="left" width="71">
	<a target="_blank"
	href="'.$links[1][link].'"
	class="media_download_link"
	'.$links[1][addlink].'>'
	.(round($links[1][filesize]
	/ 104858) / 10).' MB</a>' :
	'&nbsp;</td><td>&nbsp;').'
	</td>
	</tr>
	</table>
	</td>
	<td width="270" valign="bottom">
	<div class="list_title">
	<a
	href="page.php?id='.$item[rel_id].'"
	class="list_title_link">'.$item[baz].'</a>
	</div>
	</td>
	</tr>
	<tr>
	<td align="left" width="270">
	<div class="media_text">
	'.$item[description].'
	</div>
	</td>
	</tr>
	<tr>
	<td align="left" width="270">
	<div class="media_downloads">'
	.number_format($dls)
	.' Downloads
	</div>
	</td>
	</tr>
	</table>
	</div>
	</td>
	</tr>';
	$ii++;
	} ?>
	</table>
	
	<table border="0" cellspacing="0" width="480"
	cellpadding="0" style="border-style: solid; border-color:
	#606875; border-width: 0px 1px 1px 1px;">
	<tr>
	<td>
	<div class="nav"><?php
	    if ($pagecount)
	        echo ($page + 1)
	        . " to "
	        . min(($page + SEARCHNUM), $count)
	        . " of $count";
	?></div>
	</td>
	<td align="right">
	<div class="nav"><?php
	if (!$pagecount) {
	    echo "No search results found!";
	} else {
	
	echo
	$prevlink
	$firstlink
	$prevpages
	$pagenums
	$nextpages
	$lastlink
	' | '
	$nextlink;
	
	}
	?></div>
	</td>
	</tr>
	</table>
	</td>
	
	<?php include("theme/footer.php"); ?>
	
