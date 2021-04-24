{"title": "Why won't CSRF flaws go away?"}

csrf is short for cross site request forgery, and is an attack, where your 
browser is forced to do cross site requests. This means that if you are 
logged in to site A, code from other domains can make changes on your behalf 
to site A. Say for example that 

    index.php?action=delete&id=34 

deletes a picture from your photo album. Then a simple;

    <img src="http://A/index.php?action=delete&id=34" />

would delete the picture with id 34. Your browser sends along 
session identifiers.

I see it everywhere. Small sites, big sites. Why does it still persist? The 
flaw simply won't go away. Is it PHP's fault? PHP is such an easy language, 
enabling everyone to build some useful webapp. The built-in session management 
provides super easy access to session based systems.

PHP is not to be blamed for the annoyances csrf is causing the Internet. 
csrf flaws are replicated again and again by non-computer people, and also 
computer educated people. Programmers introduce bugs and flaws.

Noncomputer people can be excused for their blissful ignorance. They just
wanna make that webapp do what it’s supposed to do. How are they supposed to 
know about the dangers lurking around the Internet? What about programmers 
with computer education? I don't know. I've checked out my university's 
computer degrees; there are no mandatory courses addressing computer security 
at the application layer. All the focus seems to be on encrypting the 
connection (e.g. SSL). A computer degree containing zero skills on application
security doesn't make sense.

What do you think? Will csrf flaws ever end?
