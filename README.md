# 🔍 Automated Recon Script

This is a Bash-based automated recon pipeline built for efficient, modular reconnaissance. It performs passive and active enumeration using top-tier tools like `subfinder`, `amass`, `httpxgo`, `dnsx`, `hakrawler`, `nmap`, `ffuf`, and `eyewitness`. 

Many of the tools are routed through `proxychains` to allow traffic anonymization through SOCKS proxies or Tor — giving you stealth where it matters. Output is neatly organized into timestamped directories with subfolders for passive, active, and visual (screenshots) results.

Ideal for CTFs, bug bounty recon, OSINT campaigns, or building a clean GitHub portfolio.

## 📦 Tools Used

- [`subfinder`](https://github.com/projectdiscovery/subfinder)
- [`amass`](https://github.com/owasp-amass/amass)
- [`dnsx`](https://github.com/projectdiscovery/dnsx)
- [`httpxgo`](https://github.com/projectdiscovery/httpx)
- [`hakrawler`](https://github.com/hakluke/hakrawler)
- [`nmap`](https://nmap.org/)
- [`ffuf`](https://github.com/ffuf/ffuf)
- [`eyewitness`](https://github.com/FortyNorthSecurity/EyeWitness)

## 🚀 Usage

```bash
./recon.sh example.com
```

## Script 

```bash 
#!/bin/bash
set -e

DOMAIN="$1"
OUTDIR="recon-$DOMAIN"
mkdir -p $OUTDIR/passive $OUTDIR/active $OUTDIR/screenshots

echo "[*] Running subfinder..."
proxychains subfinder -d $DOMAIN -o $OUTDIR/passive/subdomains_subfinder.txt

echo "[*] Running amass..."
proxychains amass enum -passive -d $DOMAIN -o $OUTDIR/passive/subdomains_amass.txt

echo "[*] Combining subdomsudains..."
cat $OUTDIR/passive/subdomains_*.txt | sort -u > $OUTDIR/passive/subdomains_combined.txt

echo "[*] Resolving subdomains with dnsx..."
proxychains dnsx -l $OUTDIR/passive/subdomains_combined.txt -o $OUTDIR/passive/dns_resolved.txt

echo "[*] Probing HTTP/S services with httpx..."
proxychains httpxgo -l $OUTDIR/passive/dns_resolved.txt -o $OUTDIR/passive/httpx_live_hosts.txt -tech-detect -status-code -title

echo "[*] Crawling live endpoints with hakrawler..."
echo "$DOMAIN" | hakrawler -d 2 -u > "$OUTDIR/passive/hakrawler_urls.txt"

echo "[*] Running Nmap scan..."
proxychains nmap -iL $OUTDIR/passive/dns_resolved.txt -T4 -Pn -oN $OUTDIR/active/portscan_nmap.txt

echo "[*] Fuzzing common admin dirs with ffuf..."
ffuf -w /usr/share/wordlists/dirb/common.txt -u https://$DOMAIN/FUZZ -o $OUTDIR/active/fuzz_ffuf_admin.txt

echo "[*] Taking screenshots with eyewitness..."
eyewitness --web -f $OUTDIR/passive/httpx_live_hosts.txt -d $OUTDIR/screenshots/eyewitness --no-prompt

echo "[+] Recon complete. Report in $OUTDIR/"
```

Outputs are saved in recon-example.com/ with subfolders for passive/active/screenshots.

## 🌐 Proxychains Support
Some tools like subfinder, amass, and httpxgo are executed through proxychains to route traffic via configured SOCKS proxies or Tor for anonymized reconnaissance.

Make sure your proxy settings are correctly configured in `/etc/proxychains.conf`, and test with:

```bash
proxychains curl https://ifconfig.me
```
To disable proxying, comment out or remove proxychains from the relevant lines in recon.sh.

## 🛠️ Prerequisites
Make sure these tools are installed and available in $PATH. Use apt, go install, or your package manager of choice to install them.


## Notes
Wordlist path is hardcoded to /usr/share/wordlists/dirb/common.txt. Adjust as needed.

Eyewitness assumes GUI dependencies (e.g., for Kali Linux).

httpxgo can be swapped with httpx if you use the regular build.

