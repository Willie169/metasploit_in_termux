# Metasploit in Termux

[![GitHub Actions CI](https://github.com/Willie169/metasploit_in_termux/actions/workflows/termux-metasploit-arm64.yml/badge.svg)](https://github.com/Willie169/metasploit_in_termux/actions/workflows/termux-metasploit-arm64.yml)
![GitHub Repo stars](https://img.shields.io/github/stars/Willie169/metasploit_in_termux?style=social)

## How to Install

### Before

1. Install latest Termux version from [F-Droid](https://f-droid.org/en/packages/com.termux). (The version on Play Store is outdated. DO NOT use it.)
2. Launch Termux to initialize.
3. Type `exit` and enter to close it.
4. Reopen and follow the instructions below.

### Install

```bash
pkg install wget -y
wget https://raw.githubusercontent.com/Willie169/metasploit_in_termux/refs/heads/master/metasploit.sh
chmod +x metasploit.sh
./metasploit.sh
```

### Launch metasploit

After installation start Metasploit using the command:
```bash
msfconsole
```

## CI Testing

This installation script is automatically tested via GitHub Actions CI on `ubuntu-24.04-arm` with `termux/termux-docker` on both `arm` and `aarch64` architecture with startup and version check (`msfconsole -qx "version; exit"`) and payload generation test (`msfvenom -p windows/meterpreter/reverse_tcp`) verification.

## Fork

This repo is a fork of [gushmazuko's metasploit_in_termux](https://github.com/gushmazuko/metasploit_in_termux).

Before my forking, the original repo couldn't pass GitHub Actions CI Testing and failed to install metasploit in Termux. The following fixes and improvements are added:

- Fix Ruby 3.4.0 & Nokogiri by [qrt2](https://github.com/qrt2/msf-termux-ruby34).
- Change `grep` to without `-P` flag since it may not be available on all versions.
- Fix Bundler error by install the version specified in lock file with `gem install` directly.
- Fix SQLite3 error by clone the [repo](https://github.com/sparklemotion/sqlite3-ruby/tree/main), compile, and `gem install` directly.
- `termux-fix-shebang` the binaries.
- Go to `~` at start.

GitHub Actions CI Testing now run without error.

## Credits

- [gushmazuko's metasploit_in_termux](https://github.com/gushmazuko/metasploit_in_termux).
- [qrt2's msf-termux-ruby34](https://github.com/qrt2/msf-termux-ruby34)
