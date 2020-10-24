{"title": "Birthday attacks"}

A birthday attack tries to find collisions on cryptographic hash functions.
crc32 is not cryptographic, but it is a hash function.

The following code finds collisions easily:

    <?php
    $cache = [];
    
    // 50% chance of collision after 2^16 tries
    
    foreach(range(1, 2**16) as $foo) {
        $n = rand();
        $hashsum = crc32($n);
    
        if (isset($cache[$hashsum])) {
            print "Collision: crc32($n) == crc32({$cache[$hashsum]}) == $hashsum\n";
        } else {
            $cache[$hashsum] = $n;
        }
    }

The crc32 hashsum is 32 bits in length. After 2^16 tries there is a 50% chance of finding a collision.
