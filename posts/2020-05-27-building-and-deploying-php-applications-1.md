{"title": "Building and deploying PHP applications - PART ONE"}

*PART ONE*

Let's reinvent the wheel for educational purposes. It's useful to know how
e.g. Jenkins etc. works under the hood.

Our goal is to build and deploy a PHP application using simple tools.

Requirements:

* Create a build
* Deploy build
* Two environments: `test` and `prod`
* Automatic build and deploy once a day

## The server

Let's start from a fresh ubuntu 18.04 digital ocean droplet. Its hostname is `ubuntu` and its 
ip address is `104.248.169.147`.

Add an entry to `~/.ssh/config` for convenience:

    Host ubuntu
        Hostname 104.248.169.147

Let's not bother with DNS so put this into into `/etc/hosts`:

    104.248.169.147 test.example.com
    104.248.169.147 prod.example.com

Log in as root: `ssh -lroot ubuntu`

Create a regular account `ubuntu`:

    # useradd -d /home/ubuntu -m -s/bin/bash ubuntu
    # mkdir /home/ubuntu/.ssh
    # cp .ssh/authorized_keys /home/ubuntu/.ssh/
    # chown ubuntu:ubuntu /home/ubuntu/.ssh /home/ubuntu/.ssh/authorized_keys

Install nginx and php-fpm (PHP 7.2):

    # apt install nginx php-fpm

Configure `/etc/nginx/sites-available/default`:

    server {
        server_name test.example.com;
        listen 80;
        root /var/www/test;
        error_log /var/log/nginx/test.example.com.error.log;
        access_log /var/log/nginx/test.example.com.access.log;

        index ua.php;

        location / {
            try_files $uri $uri/ =404;
        }

        location ~ \.php$ {
            include snippets/fastcgi-php.conf;
            fastcgi_pass unix:/var/run/php/php7.2-fpm.sock;
        }
    }

    server {
        server_name prod.example.com;
        listen 80;
        root /var/www/prod;
        error_log /var/log/nginx/prod.example.com.error.log;
        access_log /var/log/nginx/prod.example.com.access.log;

        index ua.php;

        location / {
            try_files $uri $uri/ =404;
        }

        location ~ \.php$ {
            include snippets/fastcgi-php.conf;
            fastcgi_pass unix:/var/run/php/php7.2-fpm.sock;
        }
    }

Reload: `systemctl reload nginx`.

Create document root for test and production:

    # mkdir /var/www/{test,prod}
    # chown ubuntu:ubuntu /var/www/{test,prod}

* `/var/www/test/` the test environment
* `/var/www/prod/` the production environment

The `test` and `prod` environments are now accessible at:

<http://test.example.com/>

<http://prod.example.com/>

Exit and login as `ubuntu`:

    $ ssh -lubuntu ubuntu

Create folders:

    $ mkdir ~/{app,bin}

The `~/app` contains the application source code and `~/bin` contains
our bash scripts.

Update `PATH` and source `~/.bashrc`:

    $ echo "PATH=~/bin/:$PATH" >> .bashrc
    $ . .bashrc

The application has a single file `ua.php` which prints the browser's ua:

    <?php

    print $_SERVER['HTTP_USER_AGENT'] ?? 'not set';

Set permission: `chmod 700 ~/app/ua.php`

## The build script

We are going to do our work in `~/jobs/test` so create it and some other
useful folders:

    mkdir -p ~/jobs/test/{builds,workspace}

Create the script `~/bin/fetch`:

    #!/bin/bash

    set -euf -o pipefail

    cp -vr "$2/." "$1/workspace"

Create the script `~/bin/build`:

    #!/bin/bash

    set -euf -o pipefail

    NAME=$1/builds/$(date '+%Y-%m-%d_%H_%M_%S').tgz

    tar -czf "$NAME" -C "$1/workspace" .

    echo "$NAME"

Make them executable: `chmod +x ~/bin/{fetch,build}`, and run them:

    $ fetch ~/jobs/test ~/app
    '/home/ubuntu/app/./ua.php' -> '/home/ubuntu/jobs/test/workspace/./ua.php'

    $ build ~/jobs/test
    /home/ubuntu/jobs/test/builds/2020-05-30_18_23_47.tgz

## The deploy script 

Create the script `~/bin/deploy` which deploys a build to the specified environment:

    #!/bin/bash

    set -euf -o pipefail

    tar -xvf "$1" -C "$2"

Make it executable: `chmod +x ~/bin/deploy`, deploy our build to the `test` environment:

    $ deploy /home/ubuntu/jobs/test/builds/2020-05-30_18_23_47.tgz /var/www/test
    ./
    ./ua.php
    ./.ua.php.swp

Oh no. The swap file created by Vim was accidentally deployed.
[This is not good](https://feross.org/cmsploit/).

    $ curl -s http://test.example.com/.ua.php.swp | file -
    /dev/stdin: Vim swap file, version 8.1, pid 22552, user ubuntu, host ubuntu ...

## Unwanted files

This highlights a problem. We probably shouldn't create a build directly from a dirty application source folder. Because
we run the risk of creating a build with unwanted files.

Let's put the application into a git repository and create a build based off of a fresh clone.

Create a git repository in `~/app`

    $ cd ~/app
    $ git init
    Initialized empty Git repository in /home/ubuntu/app/.git/
    $ git add ua.php 
    $ git commit -m'init'
    [master (root-commit) 015fd8f] init
     1 file changed, 4 insertions(+)
     create mode 100700 ua.php

Create the script `~/bin/fetch-git` which clones a git repository into the workspace:

    #!/bin/bash

    set -euf -o pipefail

    rm -rf "$1/workspace"

    git clone "$2" "$1/workspace"

Clean out `/var/www/test/`:

    $ rm /var/www/test/.ua.php.swp
    $ rm -rf /var/www/test/.git

Try again:

    $ fetch-git ~/jobs/test ~/app
    Cloning into '/home/ubuntu/jobs/test/workspace'...
    done.

    $ build ~/jobs/test
    /home/ubuntu/jobs/test/builds/2020-05-30_18_34_13.tgz

    $ deploy /home/ubuntu/jobs/test/builds/2020-05-30_18_34_13.tgz /var/www/test
    ./
    ./.git/
    ./.git/index
    ./.git/refs/
    ./.git/refs/heads/
    ./.git/refs/heads/master
    ./.git/refs/remotes/
    ./.git/refs/remotes/origin/
    ./.git/refs/remotes/origin/HEAD
    ./.git/refs/tags/
    ./.git/logs/
    ./.git/logs/refs/
    ./.git/logs/refs/heads/
    ./.git/logs/refs/heads/master
    ./.git/logs/refs/remotes/
    ./.git/logs/refs/remotes/origin/
    ./.git/logs/refs/remotes/origin/HEAD
    ./.git/logs/HEAD
    ./.git/branches/
    ./.git/info/
    ./.git/info/exclude
    ./.git/description
    ./.git/objects/
    ./.git/objects/76/
    ./.git/objects/76/c4d9c8fae9ade58307d884a9a0dc6fab199e3d
    ./.git/objects/info/
    ./.git/objects/95/
    ./.git/objects/95/49afe5553992cd2186a8b6b03376dff5b9637e
    ./.git/objects/db/
    ./.git/objects/db/af0b2d6a862b2ace5510f11bbb8046147e9f19
    ./.git/objects/pack/
    ./.git/HEAD
    ./.git/config
    ./.git/hooks/
    ./.git/hooks/pre-rebase.sample
    ./.git/hooks/update.sample
    ./.git/hooks/pre-commit.sample
    ./.git/hooks/applypatch-msg.sample
    ./.git/hooks/pre-push.sample
    ./.git/hooks/post-update.sample
    ./.git/hooks/prepare-commit-msg.sample
    ./.git/hooks/fsmonitor-watchman.sample
    ./.git/hooks/commit-msg.sample
    ./.git/hooks/pre-receive.sample
    ./.git/hooks/pre-applypatch.sample
    ./.git/packed-refs
    ./ua.php


Oh no. The entire `.git` folder was deployed.
[This is not good](https://en.internetwache.org/dont-publicly-expose-git-or-how-we-downloaded-your-websites-sourcecode-an-analysis-of-alexas-1m-28-07-2015/).

Let's delete the `.git` folder in `~/bin/fetch-git`:

    #!/bin/bash

    set -euf -o pipefail

    rm -rf "$1/workspace"

    git clone "$2" "$1/workspace"

    rm -rf "$1/workspace/.git"

Try again:

    $ rm -rf /var/www/test/.git

    $ fetch-git ~/jobs/test ~/app
    Cloning into '/home/ubuntu/jobs/test/workspace'...
    done.

    $ build ~/jobs/test
    /home/ubuntu/jobs/test/builds/2020-05-30_18_38_07.tgz

    $ deploy /home/ubuntu/jobs/test/builds/2020-05-30_18_38_07.tgz /var/www/test
    ./
    ./ua.php

All is well. But if someone were to commit a sensitive file it would get exposed by nginx. Don't commit sensitive files.

Let's move all three steps into `~/jobs/test/run`:

    #!/bin/bash

    set -euf -o pipefail

    fetch-git "$1" ~/app

    BUILD=$(build "$1")

    deploy "$BUILD" /var/www/test

Make it executable `chmod +x ~/jobs/test/run` and run it:

    $ ~/jobs/test/run ~/jobs/test
    Cloning into 'PREFIX/workspace'...
    done.
    ./
    ./ua.php

## Periodic build and deploy

Let's create a cronjob that builds and deploys to the `test` environment. 
It runs each minute.

Write a crontab:

    $ crontab -e

    PATH=/bin:/usr/bin:/home/ubuntu/bin
    * * * * * $HOME/jobs/test/run $HOME/jobs/test >> $HOME/jobs/test/cronjob.log 2>&1

## Lint

Let's add a build step that lints the application.


Create `~/bin/lint-php`:

    #!/bin/bash

    set -euf -o pipefail

    php -l "$1/workspace/ua.php"

Make it executable: `chmod +x ~/bin/lint-php`.

And run it from `~/jobs/test/run`:

    ...
    lint-php "$1"
    ...

## A pattern emerges

The *job* abstraction emerges. And it does the following:

* Fetches the source code (source code managment)
* Prepares correct file permissions
* Inspect the source code for errors (lint)
* Creates a build (packaging)
* Deploys the build to an environment
* Writes to log
* Periodically repeat itself (cronjob)

## TODO

* configuration managment
* running build number
* opcache
* restart nginx
* tls certs
* process/job managment
* health checks
* notification from failed jobs
* use bash trap
* consider deb packaging
* github web hooks
* storage-full check
* atomic deployment

[PART TWO](/building-and-deploying-php-applications-2) (todo)
