{"title": "Let's go for domain treasure hunting!"}

> Treasure (from Greek θησαυρός – thēsauros, meaning “treasure store”,[2]
> romanized as thesaurus) is a concentration of riches, often one which is 
> considered lost or forgotten until being rediscovered. 

The country Iceland has the top level domain `.is`. I want to find cool
domain names such that the second level domain and the top level domain `.is`
forms a word. An example is `meningit.is`. So I went and grabbed a Norwegian
wordlist:

    $ wget https://scandinavian-keyboard.googlecode.com/files/norwegian.txt

Convert to unix line endings;

    $ dos2unix norwegian.txt

Convert to utf8:

    $ iconv -f iso-8859-1 -t utf8 norwegian.txt > norwegian.utf.txt

Now the file is greppable and I want to find words ending with `is`:

    $ grep is$ norwegian.utf.txt > words.txt

Add dot right before the `is` to form domain names:

    #!/bin/bash
    
    for word in $(cat words.txt);do
        length=${#word}
        echo "${word:0:(($length-2))}.is" >> domains.txt
    done

Now I have a list of possible domain names, some of which are registered 
and some are not. Next I have to `whois` each domain and see which one is 
available. For this the `whois` tool is useful. I grep for `No entries found` 
and check the exit status:

    #!/bin/bash
     
    for domain in $(cat domains.txt);do
        whois "$domain" | grep -q "No entries found"
     
        if [ $? -ne 0 ]; then
            :
        else
            echo "$domain" >> available_is_domains.txt
        fi
    done

And now the file available\_is\_domains.txt contains a list of available 
cool domains! Some of the more interesting are [antarkt.is](http://antarkt.is), 
[pres.is](http://pres.is), [praks.is](http://praks.is) and 
[syfil.is](http://syfil.is). They are not cool if you dont understand 
Norwegian. 

