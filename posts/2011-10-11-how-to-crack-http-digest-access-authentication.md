{"title": "HTTP authentication demystified"}

HTTP provides a way for clients to authenticate themselves.
Here is the [rfc](http://tools.ietf.org/html/rfc2617) for the advanced
readers.

> Like Basic, Digest access authentication verifies that both parties
>   to a communication know a shared secret (a password); unlike Basic,
>      this verification can be done without sending the password in the
>         clear, which is Basic's biggest weakness.

## Basic Authentication Scheme

If the user agent wishes to send the userid "Aladdin" and password
"open sesame", it would use the following header field:

    Authorization: Basic QWxhZGRpbjpvcGVuIHNlc2FtZQ==

That's base64 encoding so the password is in the clear.

## Digest Access Authentication Scheme

Its purpose was to fix the Basic Authentication Scheme way of sending
plasswords in the clear.

The first time the client requests the document, a no Authorization
header is sent, so the server responds with;

    HTTP/1.1 401 Unauthorized
    WWW-Authenticate: Digest
        realm="testrealm@host.com",
        qop="auth,auth-int",
        nonce="dcd98b7102dd2f0e8b11d0f600bfb0c093",
        opaque="5ccc069c403ebaf9f0171e9517f40e41"

The client may prompt the user for the username and password, after
which it will respond with a new request, including the following
Authorization header:

    Authorization: Digest username="Mufasa",
        realm="testrealm@host.com",
        nonce="dcd98b7102dd2f0e8b11d0f600bfb0c093",
        uri="/dir/index.html",
        qop=auth,
        nc=00000001,
        cnonce="0a4f113b",
        response="6629fae49393a05397450978507c4ef1",
        opaque="5ccc069c403ebaf9f0171e9517f40e41"

There is some checksumming with MD5 happening here. Head over to
[the wiki page](https://en.wikipedia.org/wiki/Digest_Access_Authentication) 
for the details. nonces prevent replay attacks.
