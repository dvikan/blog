{"title": "How to change time of last status change of Linux file"}

Why do I want to do this? Because I tried changing it out of curiosity, and 
I could not do it, so my brain tricked me into spending some time on it.

A file has three timestamps associated with it:

    time_t    st_atime;   /* time of last access */
    time_t    st_mtime;   /* time of last modification */
    time_t    st_ctime;   /* time of last status change */

The field `st_atime` is changed by file accesses, for example, by `execve(2)`, 
`mknod(2)`, `pipe(2)`, `utime(2)` and `read(2)` (of more than zero bytes). 
The field `st_mtime` is changed by file modifications, for example, by `mknod(2)`,
 `truncate(2)`, `utime(2)` and `write(2)` (of more than zero bytes). The
 field `st_ctime` is changed by writing or by setting inode information 
(i.e., owner, group, link count, mode, etc.).

A directory listing with `ls -l` shows a timestamp, and this is the ctime.
The `stat(1)` utility shows the three timestamps along with some other info:

    $ stat tags
      File: ‘tags’
      Size: 73129       Blocks: 144        IO Block: 4096   regular file
    Device: fe00h/65024d    Inode: 5506684     Links: 1
    Access: (0644/-rw-r--r--)  Uid: ( 1000/     dag)   Gid: (  100/   users)
    Access: 2013-11-20 01:55:34.918454212 +0100
    Modify: 2013-11-20 01:55:34.918454212 +0100
    Change: 2013-11-20 01:55:34.918454212 +0100
     Birth: -


Changing the first two; `atime` and `mtime` can be done with the touch utility
 with the `-t` option like this:
    
    $ touch -t 190403061445 file

This is the year 1904, March 6 14:15.

Now `stat` yields this;

    $ stat tags
      File: ‘tags’
      Size: 73129       Blocks: 144        IO Block: 4096   regular file
    Device: fe00h/65024d    Inode: 5506684     Links: 1
    Access: (0644/-rw-r--r--)  Uid: ( 1000/     dag)   Gid: (  100/   users)
    Access: 1904-03-06 14:45:00.000000000 +0100
    Modify: 1904-03-06 14:45:00.000000000 +0100
    Change: 2013-11-20 01:56:14.775123866 +0100
     Birth: -

Changing the `ctime` however turned out to be difficult. After an intense
googling session I have learned that there are no system calls for changing 
the `ctime`. An obvious option is to unmount the filesystem, and edit the inode 
manually.

Another way to change the `ctime`, is to change the system clock and touch it:

    $ date -s "11/20/2003 01:05:00"
    $ touch file
    $ stat tags
      File: ‘tags’
      Size: 73129       Blocks: 144        IO Block: 4096   regular file
    Device: fe00h/65024d    Inode: 5506684     Links: 1
    Access: (0644/-rw-r--r--)  Uid: ( 1000/     dag)   Gid: (  100/   users)
    Access: 2003-11-20 12:48:10.206667431 +0100
    Modify: 2003-11-20 12:48:10.206667431 +0100
    Change: 2003-11-20 12:48:10.206667431 +0100
     Birth: -

