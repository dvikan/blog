{"title": "You should hash passwords in browser before transit"}

I suggest that we should start hashing users' passwords in the browser
before they are shipped off to the server. The reason is to prevent
leakage (e.g. in logs) and because users reuse passwords.

## Why hash in the first place?

![](/blogimages/whyunohash.jpg)

We do it to reduce the chance 
that passwords get stolen at rest. The classic example is a database leak.
Other possibilities are unfaithful sysadmin or anyone else who might
have access to the hashes.

## Is MD5 or sha512 good enough?

No. Primitive hashing functions are too fast
to compute and is not suitable for secure password storage. Because
when they are so fast to compute, GPUs can brute force them very fast.

The reason MD5 and sha512 should _not_ be used is
because they are too fast to compute. The collision resistance of a hash function
have zero impact on secure password storage. MD5 should _not_ be used
because it is too fast to compute. The collision resistance of MD5 is
broken, but its pre-image resistance is not. Pre-image-resistance is
the useful property when storing passwords.

## The correct way

bcrypt/scrypt/PBKDF22. These algorithms ensure each password guess
is slow.

## Hash in browser

The server do not really need to know the plaintext password.
Here are two possibilities passwords can be stolen on server:

    1. The password is accidentally logged to storage medium in plaintext and later stolen
    2. An attacker have temporarily access to box and harvests passwords
    by sniffing the network interface.

By having a browser hash a password before transit with PBKDF2 eliminates
these two possibilities. Chance of password theft is lowered and security is
increased. So why are so few websites applying this practice?

## Some problems

I realize that the produced hash actually becomes the password. An attacker 
can use this hash to authenticate. I also realize that in practice the entire
database becomes a list of plaintext passwords.

To remedy this, the hash
could possinbly be hashed again on the server side. Also on each login the server must pass the
salt to the browser so it can correctly compute the PBKDF2.

