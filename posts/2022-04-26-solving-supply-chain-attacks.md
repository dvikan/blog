{
"title": "Solving supply chain attacks"
}

Throwing out my thoughts on this subject.

A supply chain attack is when third-party software contains malware.

All the following operations can potentially compromise a machine:

* `apt upgrade`
* `pip update`
* `npm update`
* `brew update`
* `cargo update`
* `yarn update`
* `gem update`
* `composer update`

The following ideas depends on the threat model. There are no solutions, only tradeoffs.

## Library splitting by complexity

Most projects do not need a general-purpose http client.
Often you just want to do a few GET and POST requests and that's it.
When you pull in a general-purpose http-client you often get 
a huge amount of code units. E.g. `composer.phar require guzzlehttp/guzzle:^7.0`
has 45 classes and three other dependencies.

I'm thinking a library could possibly be split into two packages:

* http-client-simple
* http-client-complex (general-purpose)

The simple version of a library might only be a single class. It has 
a reduced feature set, but the code is smaller, has less bugs and is probably more
secure. Code review is faster. Harder to slip in malware.

## Common sense

* Do not depend on a random package you found that was created yesterday
* Do not directly depend on 9000 packages
* Do not transitively depend on 9000 packages
* Do a dry run upgrade: `blox --dry-run uprade`

## Version locking

The latest version is not always needed.
Lock a dep to e.g. `v1.2.3`.
Some dependency managers allow you to lock `v1.*` to only get patches and minors.
Don't blindly upgrade major versions.

## Code review

If not too much work, exert 5 mins on a  code review:

    git add ./vendor
    # upgrade
    git diff ./vendor

## Sandboxing (containers, VMs)

Maybe we should all start developing software in containers/VMs?

## Disable post-install tasks

Some package managers has features where a task can be executed at different lifecycles.

E.g. composer:

    # Skips execution of scripts defined in composer.json.`
    composer --no-scripts update 

## Issue frequency anomaly

If there is an unusual amount of activity in the offending issue tracker, it's worth checking out.

## Inline packages and semi-adopt them

Are you depending on a package which is only one function or a single file?
Why not just inline it?

    mkdir -p ./vendor-inlined
    curl "https://raw.githubusercontent.com/lborgav/is-prime/master/index.js" -o ./vendor-inlined/is-prime.js

## Package consolidation

There are lots of packages that possibly could be consolidated into a single package.

## Code scanning

Code scan for dangerous functions e.g. `eval()`.

## Suspicious versioning

Detect suspicious versioning patterns.
