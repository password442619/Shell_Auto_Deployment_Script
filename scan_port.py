#!/usr/bin/python
# -*- coding: utf-8 -*-
import sys
import nmap

scan_row = []
input_data = raw_input('Please input hosts and port:')
scan_row = input_data.split(" ")
if len(scan_row)!=2:
	print "Input errors,example \"192.168.2.0/24 80,443,22\""
	sys.exit(0)
hosts = scan_row[0]
port = scan_row[1]
