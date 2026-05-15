# Metasploit Framework 6 in Termux
[![GitHub Actions CI](https://github.com/gushmazuko/metasploit_in_termux/actions/workflows/termux-metasploit-arm64.yml/badge.svg)](https://github.com/gushmazuko/metasploit_in_termux/actions/workflows/termux-metasploit-arm64.yml) ![GitHub Repo stars](https://img.shields.io/github/stars/gushmazuko/metasploit_in_termux?style=social)

![Metasploit 6 running](https://i.imgur.com/yLFQhvP.png)

## How to Install
### Before

1. Install latest Termux version from [F-Droid](https://f-droid.org/en/packages/com.termux). (The version on Play Store is outdated.)
2. Launch Termux to initialize.
3. Type `exit` and enter to close it.
4. Reopen and follow the instructions below.

### Install
```bash
pkg install wget -y
wget https://raw.githubusercontent.com/gushmazuko/metasploit_in_termux/refs/heads/master/metasploit.sh
chmod +x metasploit.sh
./metasploit.sh
```

### Launch metasploit
After installation start Metasploit using the command:
```bash
msfconsole
```

## Testing
This installation script is automatically tested via GitHub Actions CI on ARM64 architecture to ensure reliability:

- ✅ **Dependencies Installation**: All required packages install correctly on ARM64
- ✅ **Metasploit Framework**: Complete installation and build verification
- ✅ **msfconsole**: Startup and version check (`msfconsole -qx "version; exit"`)
- ✅ **msfvenom**: Payload generation test (`msfvenom -p windows/meterpreter/reverse_tcp`)
- ✅ **DNS Resolution**: Comprehensive hosts file for Termux container networking

The CI pipeline runs on `ubuntu-24.04-arm` with `termux/termux-docker:aarch64` to match real-world ARM64 usage scenarios.
