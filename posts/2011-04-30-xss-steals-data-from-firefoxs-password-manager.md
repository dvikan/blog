{"title": "XSS steals data from Firefox's password manager"}

When you enter data in a login form, Firefox ask if I want to save that login
for future logins. I use this feature all the time and have about 20-30 logins
saved in Firefox. Whenever I visit a site, and Firefox has login credentials 
associated with that site, Firefox automatically fills in values in to the DOM. 
This way you can simply hit submit.

1. Find xss bug.

2. Load the login form into the DOM

3. Use javascript to access the data

Usually, users are already logged in, so the login form is not available. 
Then you could simply log the user out first by forcing;

    GET /logout.php.

You also have to wait for the page to fully have loaded, before you can access 
data.

I think [RSnake](http://ha.ckers.org/) in 2006, was the first to publicly talk about this technique.
