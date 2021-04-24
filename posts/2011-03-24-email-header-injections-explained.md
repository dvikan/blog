{"title": "Email header injections explained"}

The principle is simple. When user input is used in different contexts, they 
mean different things. Html code means nothing in a pure ascii file. 
Sql commands mean nothing in a C compiler. And javascript means nothing in 
photshop. But if the right kind of meta characters are used in a 
spesific context, they can be highly dangerous.

One example of this is sql injections. Characters like ' and -- suddenly have
a big impact on the query.

The metacharacter in email header injections is the line feed, 'n', 0x0a, or
10 in decimal. Urlencoded it is %0a. This is because the newline separates 
headers in emails. Here is an example of an email;

    To: recipient@victim.xxx
    Subject: Hello
    From: sender@anonymous.xxx
     
     Hi,
     Your site is great.
     Bye

When an attacker can change data which goes into headers, he can simply add a 
newline and put in whatever headers he may prefer.

An example of injecting a header in the "From" field;

    sender@anonymous.xxx%0ACcc: test@test.com

The resulting email will look like this:

    To: recipient@victim.xxx
    Subject: Hello
    From: sender@anonymous.xxx
    Cc: test@test.com
    
    Hi,
    Your site is great.
    Bye

Which fill fire off a blind carbon copy to test@test.com.

This technique is used by spammers to spread their spam. The spammers 
construct very specific header injections, which will change the subject 
and the body.

## prevention

A simple blacklist approach where you strip away all newlines may seem viable.
But for maximum security, one should also account for unknown attacks. 
The best solution would be a regular expression which checks for valid 
email adresses.
