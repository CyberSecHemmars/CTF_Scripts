#!/bin/bash

# Author: Hemmars
# Project: CTF script


# Usage: $0 <IP> <Target_Name>

# Argument Input
IP="$1"
Target_Name="$2"

# Text Animation
effect () {
    local text="$1"
    local length=${#text}
    local time_break=0.035

    for (( i = 0; i < length; i++ )); do
        echo -n "${text:i:1}"
        sleep $time_break
    done
    echo ""
}

# Clearing the Terminal
sleep 1
effect "[+] Clearing Terminal..."

sleep 2
clear
sleep 1

effect "[+] Starting..."
sleep 2
echo ""
sleep 1

# Argument Alternative
if [ "$#" -ne 2 ]; then
    effect "[+] Collecting Target Name"
    read -p "Enter Target Name: " Target_Name
    sleep 0.5
    effect "[+] Collecting Target IP Address"
    read -p "Enter Target IP Address: " IP
    sleep 0.5
    echo ""
fi

# Validating IP Address
effect "[+] Validating Target IP Address..."
sleep 2
if ! echo "$IP" | grep -P "^\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}$" > /dev/null; then
	effect "The Target IP Address \"$IP\" is Invalid."
	effect "Please, Enter a Valid IP Address."
	exit 1
else
	effect "The Target IP Address \"$IP\" is Valid."
	echo ""
fi

# Pinging IP Address
sleep 1
effect "[+] Pinging Target IP Address..."
ping -c 3 "$IP" > /dev/null

if [ "$?" -ne 0 ]; then
    effect "The Target IP Address \"$IP\" is down."
    exit 1
else
    effect "The Target IP Address \"$IP\" is up."
    echo ""
fi

sleep 1

# This creates a directory, Target_Name
if [ ! -d "$Target_Name" ]; then
    effect "[+] Creating Directory $Target_Name..."
    mkdir -p "$Target_Name" -v || { effect "Error creating directory: $Target_Name"; exit 1; }
    echo ""
fi

sleep 1

# This creates a sub-directory recon 
if [ ! -d "$Target_Name/recon" ]; then
    effect "[+] Crea]ting Recon Directory..."
    mkdir -p "$Target_Name/recon" -v || { effect "Error creating directory: recon"; exit 1; }
    echo ""
fi

# This creates a sub-directory enum
if [ ! -d "$Target_Name/enum" ]; then
    effect "[+] Creating Enum Directory..."
    mkdir -p "$Target_Name/enum" -v || { effect "Error creating directory: enum"; exit 1; }
    echo ""
fi


# This creates a sub-directory report
# if [ ! -d "$Target_Name/report" ]; then
#    effect "[+] Creating Report Directory..."
#    mkdir -p "$Target_Name/report" -v || { effect "Error creating directory: report"; exit 1; }
#   echo ""
# fi


sleep 1

# recon with Nmap
effect "[+] Reconnassancing with Nmap..."
if [ ! -f "$Target_Name/recon/nmap.txt" ]; then
    sudo nmap -A -p- -T4 "$IP" > "$Target_Name/recon/nmap.txt" || { effect "Error Reconnassancing with Nmap"; exit 1; }
    effect "Nmap scan results saved to $Target_Name/recon/nmap.txt"
else
    sleep 2
    effect 'The file "nmap.txt" already exists, skipping scan.'
fi

sleep 1
echo ""
effect "[+] Viewing Nmap Scan Results"
nmap_scan=$(cat "$Target_Name/recon/nmap.txt")
sleep 2

# HTTP/HTTPS Scan
if echo "$nmap_scan" | grep -qE "80/tcp|443/tcp"; then
    echo ""
    sleep 2
    effect "[-] HTTP/HTTPS is open."
    sleep 2

    #Firefox Preview
    effect '[+] Previewing "$IP" with Firefox Browser...'
    echo ""
    if command -v firefox &>/dev/null; then
        firefox http://"$IP" &
    else
	sleep 2
        effect "Firefox Browser not found."
    fi

sleep 1

    # Nikto Scan
    effect "[+] Reconnassacing with Nikto..."
    if [ ! -f "$Target_Name/recon/nikto.txt" ]; then
        nikto -h http://"$IP" > "$Target_Name/recon/nikto.txt"
        effect "Nikto scan results saved to $Target_Name/recon/nikto.txt"
    else
	sleep 2
        effect 'The file "nikto.txt" already exists, skipping scan.'
    fi
    
echo ""
sleep 1
    # WhatWeb Scan
    effect "[+] Reconnassacing with WhatWeb..."
    if [ ! -f "$Target_Name/recon/whatweb.txt" ]; then
        whatweb http://"$IP" > "$Target_Name/recon/whatweb.txt"
        effect "WhatWeb scan results saved to $Target_Name/recon/whatweb.txt"
    else
	sleep 2
        effect 'The file "whatweb.txt" already exists, skipping scan.'
    fi

echo ""
sleep 1
    # Dirb Scan
    effect "[+] Busting Directories with Dirb..."
    if [ ! -f "$Target_Name/recon/dirb.txt" ]; then
        dirb http://"$IP" -r > "$Target_Name/recon/dirb.txt"
        effect "Dirb results saved to $Target_Name/recon/dirb.txt"
    else
	sleep 2
        effect 'The file "dirb.txt" already exists, skipping scan.'
    fi

echo ""
else
	sleep 2
	echo ""
	effect "[-] HTTP/HTTPS is closed."
fi

# SMB Scan
if echo "$nmap_scan" | grep -qE "139/tcp|445/tcp"; then
    echo ""
    sleep 2
    effect "[-] SMB is open."
    sleep 2
    
    # SMB Enumeration with Nmap
    effect "[+] Enumerating SMB with Nmap..."
    if [ ! -f "$Target_Name/enum/smb.txt" ]; then
        nmap -p 139,445 --script smb-enum* "$IP" > "$Target_Name/enum/smb.txt"
        effect "SMB scan results saved to $Target_Name/enum/smb.txt"
    else
        effect 'The file "smb.txt" already exists, skipping scan.'
    fi
else
        sleep 2
        effect "[-] SMB is closed."
fi

# FTP Scan

if echo "$nmap_scan" | grep -qE "21/tcp"; then
    echo ""
    sleep 2
    effect "[-] FTP is open."
    sleep 2

# FTP Enumeration with Nmap
    effect "[+] Enumerating FTP with Nmap..."
    if [ ! -f "$Target_Name/enum/ftp.txt" ]; then
        nmap --script ftp-* -p 21 "$IP" > "$Target_Name/enum/ftp.txt"
        effect "FTP scan results saved to $Target_Name/enum/ftp.txt"
    else
        effect 'The file "ftp.txt" already exists, skipping scan.'
    fi
else
	sleep 2
	effect "[-] FTP is closed."
fi

# SSH Scan

if echo "$nmap_scan" | grep -qE "22/tcp"; then
    echo ""
    sleep 2
    effect "[-] SSH is open."
    sleep 2

# SSH Enumeration with Nmap
    effect "[+] Enumerating SSH with Nmap..."
    if [ ! -f "$Target_Name/enum/ssh.txt" ]; then
        nmap --script ssh-* -p 22 "$IP" > "$Target_Name/enum/ssh.txt"
        effect "SSH scan results saved to $Target_Name/enum/ssh.txt"
    else
        effect 'The file "ssh.txt" already exists, skipping scan.'
    fi
else
        sleep 2
        effect "[-] SSH is closed."
fi

sleep 5

effect "Script has been completed."
effect "Thank You..."
