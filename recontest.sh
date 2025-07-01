#!/bin/bash
set -e

DOMAIN=$1
OUTDIR="recon-$DOMAIN"
mkdir -p $OUTDIR/passive $OUTDIR/active $OUTDIR/screenshots

echo "[*] Running subfinder..."
subfinder -d $DOMAIN -o $OUTDIR/passive/subdomains_subfinder.txt

echo "[*] Running amass..."
amass enum -passive -d $DOMAIN -o $OUTDIR/passive/subdomains_amass.txt

echo "[*] Combining subdomains..."
cat $OUTDIR/passive/subdomains_*.txt | sort -u > $OUTDIR/passive/subdomains_combined.txt

echo "[*] Resolving subdomains with dnsx..."
dnsx -l $OUTDIR/passive/subdomains_combined.txt -o $OUTDIR/passive/dns_resolved.txt

echo "[*] Probing HTTP/S services with httpx..."
httpx -l $OUTDIR/passive/dns_resolved.txt -o $OUTDIR/passive/httpx_live_hosts.txt -tech-detect -status-code -title

echo "[*] Fetching URLs from gau..."
gau $DOMAIN > $OUTDIR/passive/gau_urls.txt

echo "[*] Fetching URLs from Wayback..."
cat $OUTDIR/passive/subdomains_combined.txt | waybackurls > $OUTDIR/passive/waybackurls.txt

echo "[*] Running Nmap scan..."
nmap -iL $OUTDIR/passive/dns_resolved.txt -T4 -Pn -oN $OUTDIR/active/portscan_nmap.txt

echo "[*] Fuzzing common admin dirs with ffuf..."
ffuf -w /usr/share/wordlists/dirb/common.txt -u https://$DOMAIN/FUZZ -o $OUTDIR/active/fuzz_ffuf_admin.txt

echo "[*] Taking screenshots with aquatone..."
cat $OUTDIR/passive/httpx_live_hosts.txt | aquatone -out $OUTDIR/screenshots

echo "[+] Recon complete. Report in $OUTDIR/"

