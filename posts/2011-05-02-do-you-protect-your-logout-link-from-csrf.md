{"title": "Do you protect your logout link from CSRF?"}

The logout link is vulnerable to CSRF just like any other action that has an 
effect. It's not very dangerous to be affected by a logout attack, but it 
could be annoying. Especially if a users on a forum can put HTTP links as 
their profile picture etc. Then every user would be logged out each time time
they viewed that profile picture.

    <img src="http://victim/logout.php">
