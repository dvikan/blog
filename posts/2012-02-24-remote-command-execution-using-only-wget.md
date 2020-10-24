{"title": "Remote command execution using only wget"}

I have discovered a method to get remote command execution on your machine.
To demonstrate, I first need you to fetch this google url using `wget`:

    wget -q www.google.com/support?tid=;id;#g54g23df233d

Do you see what I did there? If you didn't catch it, there is an `id` inside 
the url. 

Be careful when pasing stuff into your shell.
