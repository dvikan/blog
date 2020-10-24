{"title": "Useful unix tools herein"}

## Toggle keyboard layout

    setxkbmap -query | grep -q "layout:\s\+us" && setxkbmap no || setxkbmap us

## Count lines of code in .php files (using awk!)

    find src -name '*.php' -exec wc -l {} \; | awk '{sum += $1} END {print sum}'

## Useful svn stuff

    // Ignore multiple files
    svn propedit svn:ignore .

## Generate tags for php code

    ctags -f php.tags --languages=PHP -R app

## Flush ARP table

    ip -s -s neigh flush all

## Add user to group

    usermod -a -G sudo jon

## Printer markdown document

    markdown referat-2016-04-15.md | iconv -f utf-8 -t iso-8859-1 | html2ps | lpr

## VIM: compile markdown on save

    :autocmd BufWritePost *.md !markdown % > /tmp/%.html

## Open up SSH access for one machine

Remember to save the changes so they persist after reboot.

    iptables -A INPUT -s 192.168.0.5 -p tcp --dport 22 -j ACCEPT

## Increase keyboard repetition key and delay

    xset r rate 200 60

## Set HDMI port output

    xrandr --output HDMI-0 --right-of VGA-0 --auto

## SSH VPN

    ssh -4 -v -p 22 -N -D 1080 user@host

## Snag x509 certs

    openssl s_client -showcerts -connect dvikan.no:443
    openssl s_client -connect dvikan.no:443 </dev/null | sed -n -e '/-BEGIN CERTIFICATE-/,/END CERTIFICATE-/p' > dvikan.no.crt
    openssl x509 -in my.crt

## Set jobname and username on printerjob

    lpr -J jobname -U username -m -p

## Find largest files

    du -a| sort -n -r

## Have chromium use a proxy

    chromium   --proxy-server=socks5://localhost

## Extract a 10s clip from video

    ffmpeg -ss 00:13:30 -i hello.mkv -t 120 -c copy -map 0 1.mkv

## check permisions up to root

    namei -l $(pwd)

## Record screen

    ffmpeg -f x11grab -s 1920x1080  -r 25 -i :0.0  /tmp/out.mkv

## Make proper screencast

    ffmpeg -video_size 1920x1080 -framerate 25 -f x11grab -i :0.0 -vcodec libx264 -crf 0 -preset ultrafast output.flv
    ffmpeg -i output.flv -b:v 1M output.webm

## Add static route

    ip route add 80.76.158.94 dev enp2s0 # do not route tv6play.no via vpn

## Release ip, change mac, then request new ip

    sudo dhcpcd -k enp2s0 ;sudo macchanger -e enp2s0; sudo systemctl start dhcpcd@enp2s0

## Iterate over a number and using curl

    for i in $(seq -w 1 999);do
        h="http://hello.no/sales/2029876${i}/";
        curl --silent -q "$h" | grep -q 404 || echo FOUND EVENT $h;
    done

## Combine two PDFs into one

    gs -dBATCH -dNOPAUSE -q -sDEVICE=pdfwrite -sOutputFile=merged.pdf cv/cv.pdf karakterutskrifter/grades-v20140001.pdf

## Poor man's steganography

    echo %PDF-1.4 | cat - passwordz.txt > nothing-to-see-here.pdf

## Find prefix md5 hash collions on "dead"

    for i in $(seq 1 10000);do ret=$(echo $i | md5sum -) ; if [[ "${ret:0:4}" == "dead" ]];then echo $ret; fi;done

## Find files modified last 5 days

    find . -mtime -5

## Create VM with debian image

    qemu-img create -f qcow2 diskfile 4G
    qemu-system-x86_64 --enable-kvm -m 512 -cdrom downloads/debian-7.4.0-amd64-netinst.iso -boot order=d diskfile
    qemu-system-x86_64 --enable-kvm -m 512 diskfile

## Find duplicate files

    md5sum * | sort | uniq -w 32 -D
    find -type f -exec md5sum {} \; | sort | uniq -w 32 -D

## Create a graph from datapoints

    echo "1 1
    2 45
    3 96
    4 16
    5 25
    6 36
    7 49" > datapoints
    gnuplot -p -e 'plot "datapoints" with lines'

## Remap CAPS LOCK to ESC

    xmodmap -e "clear lock"
    xmodmap -e "keycode 0x42 = Escape" 

## Set media title on mkv file

    mkvpropedit --set "title=hello" 1.mkv

## Generate secure passwod

    openssl rand -hex 8

## Change charset on file from iso8859-1 to utf8

    iconv -f iso8859-1 -t utf8 Crash.html > a;mv a Crash.html

## Extract referrers from apache access log

    awk -F\" '{print $4}' access.log  | sort | uniq -c| sort -r -n |less

## Scan image with scanner

    scanimage --device pixma:04A91709_B46AD2 --format=tiff > /tmp/a.tiff
    scanimage --device pixma:04A91709_B46AD2 --format=tiff -x 210 -y 250 --resolution=200 > /tmp/a.tiff

## Find process listening on tcp port

    netstat -t -l -p

## OCR with tesseract

    tesseract /tmp/a.tiff out -l nor
    cat out.txt
