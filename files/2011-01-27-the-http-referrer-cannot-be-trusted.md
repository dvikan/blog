{"title": "The HTTP referrer cannot be trusted"}

The HTTP referrer can't be trusted. The same goes for all the other 
HTTP headers. Why can't you trust them? Because they are user inputs.

If you want to spoof your own browsers HTTP header you can simply edit them 
on the fly with a plugin or extension. Or you could create an HTTP connection
using a programming language.

What this means is that an HTTP connection's referrer could contain html, 
javascript, php, java, xml and so on. So if you are doing referrer logging, 
remember to only let through safe characters.

## oh btw

Maybe you thought referrer checking prevents csrf attacks? A simple meta refresh 
blanks out the referrer:

    <meta http-equiv="refresh" content="0;url=http://attacker/CSRF.html">
