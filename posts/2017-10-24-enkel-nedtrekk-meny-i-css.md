{"title": "Enkel nedtrekk meny i CSS"}

Jeg har strevd litt med å lage en nedtrekkmeny i CSS. Forskjellige eksempler
på internett har overraskende lange CSS-regler.

Hvorfor ikke gjøre det simpelt.

## Simpelt

HTML:

    <ul class="dropdown">
    
        Menu
    
        <li>
            <a href="#">foo</a>
        </li>
    
        <li>
            <a href="#">bar</a>
        </li>
    </ul>

CSS:

    .dropdown
    {
        display: inline-block;
        padding: 0;
        list-style: none;
    }
    
    .dropdown > li
    {
        display: none;
    }
    
    .dropdown:hover > li
    {
        display: block;
    }

Det trikset som benyttes her er `.dropdown:hover > li` som setter `li` elementene til `display: block`
når `ul-en` får musepeker over seg.    

CSS-reglene er gjenbrukbare.

For theming bør CSS-reglene subclasses med f.eks:

    .dropdown-bloody > li
    {
        background-color: red;
    }

## Eksklusive screenshots

![]({{ site.url }}/blogimages/css-meny1.png)
![]({{ site.url }}/blogimages/css-meny2.png)

## Demo

Noe av stylingen er påvirket av bloggen sitt CSS-tema.

<ul class="dropdown">

    Menu

    <li>
        <a href="#">foo</a>
    </li>

    <li>
        <a href="#">bar</a>
    </li>
</ul>

<style>
.dropdown
{
    display: inline-block;
    padding: 0;
    list-style: none;
}

.dropdown > li
{
    display: none;
}

.dropdown:hover > li
{
    display: block;
}
.dropdown-bloody > li
{
    background-color: red;
}
</style>
