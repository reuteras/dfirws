#!/usr/bin/python3

import sys
import ipaddress


if len(sys.argv) < 2:
    print("Usage: ipexpand <range>")
    print("")
    print("Example: ipexpand 192.168.1.0/24")
    sys.exit()

for network in sys.argv[1:]:
    try:
        net = ipaddress.ip_network(network)
    except:
        print('ERROR: Invalid network range! Did you end with .1?')
        sys.exit()

    for ip in net:
        print(ip)
