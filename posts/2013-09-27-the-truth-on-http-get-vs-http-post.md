{"title": "The truth on HTTP GET vs HTTP POST"}

Which one should be used for web application forms? As a rule, the HTTP
protocol defines POST for things that may have side effects, and GET
is for read only viewing.

## tls and sniffing ninjas

If an eavesdropper is able to sniff your traffic it does not make any 
difference if you use GET or POST.
The POST and GET parameters are both in plaintext inside the HTTP message.

## Browser history

GET parameters are cached in the browser history. 

## Server logging

A web server typically logs GET parameters but not POST parameters.
Server logs may be stolen or archived.

## duplications

Browsers typically warn the user if hitting the back button on a POST
submissions.
This is to prevent duplicate form submissions. This is a good thing.

## csrf attacks

When GET requests have side effects, a URL can be put inside img html tags.
An attacker may put this in his profile picture:
    
    <img src="/delete/34">

Yes, any html page can do this, but using GET makes it a tiny bit esier to
cause havoc.

## HTTP referrer leakage

If the resulting page after a form submission contain references to other
servers' resources, the GET parameters are getting leaked. E.g. 
google analytics and others.
