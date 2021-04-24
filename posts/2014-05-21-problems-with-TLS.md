{"title": "3 Problems with SSL/TLS PKI"}

## Too many certificate authorities

There are 650 organizations capable of producing signatures accepted by
your popular browsers.

## Revocation is broken

CRL and OCSP are supposed to provide revocation services. If the OCSP 
lookup times out, then browsers carry on anyway. 

## The unsafe bridge from HTTP to HTTPS

At the moment in time when a browser is redirected from non-TLS to TLS
there is a window of attack. Take a look at this response:

    curl -I http://dvikan.no/
    HTTP/1.1 301 Moved Permanently
    Server: nginx/1.6.0
    Date: Wed, 21 May 2014 13:31:02 GMT
    Content-Type: text/html
    Content-Length: 184
    Connection: keep-alive
    Location: https://dvikan.no/

My blog is fully served over HTTPS and I redirect all traffic from port 80 to 443.

However, an attacker can simply strip away the `Location: https://dvikan.no/` and
put `Location: http://dvikan.no/` there instead. The next time the browser requests this
page the mitm attacker can himself do a HTTPS connection towards my site, grab the html
and send it back to victim. 

The only thing different a victim will see is that the HTTPS icon is missing. So it looks
just like a regular HTTP website. 
