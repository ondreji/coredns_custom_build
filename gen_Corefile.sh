#!/bin/bash
china=`curl -sSL https://github.com/felixonmars/dnsmasq-china-list/raw/master/accelerated-domains.china.conf | while read line; do awk -F '/' '{print $2}' | grep -v '#' ; done |  paste -sd " " -`
apple=`curl -sSL https://github.com/felixonmars/dnsmasq-china-list/raw/master/apple.china.conf | while read line; do awk -F '/' '{print $2}' | grep -v '#' ; done |  paste -sd " " -`
google=`curl -sSL https://github.com/felixonmars/dnsmasq-china-list/raw/master/google.china.conf | while read line; do awk -F '/' '{print $2}' | grep -v '#' ; done |  paste -sd " " -`
bogus=`curl -sSL https://github.com/felixonmars/dnsmasq-china-list/raw/master/bogus-nxdomain.china.conf | grep "=" | while read line; do awk -F '=' '{print $2}' | grep -v '#' ; done |  paste -sd " " -`
cat>Corefile<<EOF
. {
    ads {
        default-lists
        blacklist https://raw.githubusercontent.com/privacy-protection-tools/anti-AD/master/anti-ad-domains.txt
        whitelist https://files.krnl.eu/whitelist.txt
        log
        auto-update-interval 24h
        list-store ads-cache
    }
    hosts {
        fallthrough
    }
    forward . 127.0.0.1:5301 127.0.0.1:5302 127.0.0.1:5303 127.0.0.1:5304   {
    except $china $apple $google cdn.jsdelivr.net
    }
    proxy . 192.168.1.1
    bogus $bogus
    log
    cache
    health
    reload
}
.:5301 {
    bind 127.0.0.1
    forward . tls://9.9.9.9 tls://9.9.9.10 {
        tls_servername dns.quad9.net
    }
    cache
   ipset free 
}
.:5302 {
    bind 127.0.0.1
    forward . tls://1.1.1.1 tls://1.0.0.1 {
        tls_servername cloudflare-dns.com
    }
    cache
    ipset free 
}
.:5303 {
    bind 127.0.0.1
    forward . tls://8.8.8.8 tls://8.8.4.4 {
        tls_servername dns.google
    }
    cache
    ipset free 
}
.:5304 {
    bind 127.0.0.1
    forward .  208.67.222.222:443 208.67.222.222:5353 208.67.220.220:443 208.67.220.220:5353 
    cache
    ipset free 
}
EOF
