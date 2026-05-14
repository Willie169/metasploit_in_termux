#!/data/data/com.termux/files/usr/bin/bash

# Banner and center functions
center_banner() {
    local termwidth=$(stty size | cut -d" " -f2)

    local banner=(
        "+-+-+-+-+-+-+-+-+-+-+ +-+-+ +-+-+-+-+-+-+"
        "|M|e|t|a|s|p|l|o|i|t| |i|n| |T|e|r|m|u|x|"
        "+-+-+-+-+-+-+-+-+-+-+ +-+-+ +-+-+-+-+-+-+"
        "+-+-+ +-+-+-+-+-+-+-+-+-+-+"
        "|b|y| |G|u|s|h|m|a|z|u|k|o|"
        "+-+-+ +-+-+-+-+-+-+-+-+-+-+"
    )

    echo -e "\e[34m" # Blue color
    for line in "${banner[@]}"; do
        printf "%*s\n" $(( (termwidth + ${#line}) / 2 )) "$line"
    done
    echo -e "\e[0m" # Reset color
}

center() {
  termwidth=$(stty size | cut -d" " -f2)
  padding="$(printf '%0.1s' ={1..500})"
  printf '%*.*s %s %*.*s\n' 0 "$(((termwidth-2-${#1})/2))" "$padding" "$1" 0 "$(((termwidth-1-${#1})/2))" "$padding"
}

clear
center_banner

# Loading spinner
center "Loading..."
source <(echo "c3Bpbm5lcj0oICd8JyAnLycgJy0nICdcJyApOwoKY291bnQoKXsKICBzcGluICYKICBwaWQ9JCEKICBmb3IgaSBpbiBgc2VxIDEgMTBgCiAgZG8KICAgIHNsZWVwIDE7CiAgZG9uZQoKICBraWxsICRwaWQgIAp9CgpzcGluKCl7CiAgd2hpbGUgWyAxIF0KICBkbyAKICAgIGZvciBpIGluICR7c3Bpbm5lcltAXX07IAogICAgZG8gCiAgICAgIGVjaG8gLW5lICJcciRpIjsKICAgICAgc2xlZXAgMC4yOwogICAgZG9uZTsKICBkb25lCn0KCmNvdW50" | base64 -d)

# Dependencies Installation
center "* Dependencies installation..."
# Skip mirror selection if sources.list is already configured (for CI)
if ! grep -q "gnlug.org" /data/data/com.termux/files/usr/etc/apt/sources.list 2>/dev/null; then
  pkg update -y
else
  apt update -y
fi
DEBIAN_FRONTEND=noninteractive pkg upgrade -y -o Dpkg::Options::="--force-confnew"
pkg install -y binutils python autoconf bison clang coreutils curl findutils apr apr-util postgresql openssl readline libffi libgmp libpcap libsqlite libgrpc libtool libxml2 libxslt ncurses make ncurses-utils ncurses git wget unzip zip tar termux-tools termux-elf-cleaner pkg-config git ruby -o Dpkg::Options::="--force-confnew"
python3 -m pip install requests

# Fix Ruby 3.4.0 & Nokogiri by qrt2
# https://github.com/qrt2/msf-termux-ruby34
find $PREFIX/include -name rbasic.h -exec sed -i 's/const VALUE klass;/VALUE klass;/g' {} +

# Fix ruby BigDecimal
#center "* Fix ruby BigDecimal"
#source <(curl -sL https://github.com/termux/termux-packages/files/2912002/fix-ruby-bigdecimal.sh.txt)

# Erase Old Metasploit Folder
center "* Erasing old metasploit folder..."
if [ -d "${PREFIX}/opt/metasploit-framework" ]; then
  rm -rf ${PREFIX}/opt/metasploit-framework
fi

# Download Metasploit
center "* Downloading..."
if [ ! -d "${PREFIX}/opt" ]; then
  mkdir ${PREFIX}/opt
fi
git clone https://github.com/rapid7/metasploit-framework.git --depth=1 ${PREFIX}/opt/metasploit-framework

# Install Metasploit
center "* Installation..."
cd ${PREFIX}/opt/metasploit-framework
gem install bundler
NOKOGIRI_VERSION=$(cat Gemfile.lock | grep -i nokogiri | sed 's/nokogiri [\(\)]/(/g' | cut -d ' ' -f 5 | grep -oE '[0-9]+\.[0-9]+(\.[0-9]+)?')
# by overriding cflags nokogiri will install or you can simply declare a void function
#  you might have seen this error while installing nokogiri `xmlSetStructuredErrorFunc((void *)rb_error_list, Nokogiri_error_array_pusher);`
#  solution : void xmlSetStructuredErrorFunc(void *rb_error_list, void *Nokogiri_error_array_pusher); you can set any parameter name
#  for sake of simplicity tweaking cflags is better than declaring a void function for every c file

gem install nokogiri -v $NOKOGIRI_VERSION -- --with-cflags="-Wno-implicit-function-declaration -Wno-deprecated-declarations -Wno-incompatible-function-pointer-types" --use-system-libraries

# Fix bundler error
BUNDLER_VERSION="$(sed -n '/BUNDLED WITH/{n;s/^ *//;p}' Gemfile.lock)"
gem install bundler -v "${BUNDLER_VERSION}"

# Fix sqlite3 error
SQLITE3_VERSION=$(cat Gemfile.lock | grep -i sqlite3 | sed 's/sqlite3 [\(\)]/(/g' | cut -d ' ' -f 5 | grep -oE '[0-9]+\.[0-9]+(\.[0-9]+)?')
git clone https://github.com/sparklemotion/sqlite3-ruby.git
cd sqlite3-ruby
git checkout "v${SQLITE3_VERSION}"
gem build sqlite3.gemspec
gem install "sqlite3-${SQLITE3_VERSION}.gem" -- --enable-system-libraries
cd ..
bundle config set path.system true

gem install actionpack
bundle update activesupport
bundle update --bundler
bundle install -j$(nproc --all)

# Fix ActionView version compatibility issue for ARM64
center "* Fixing ActionView version compatibility..."
# Disable the version check entirely since ActionView 8.x might not need the monkey patch
sed -i 's/raise unless ActionView::VERSION::STRING == .*$/# Version check disabled for ARM64 compatibility/' config/application.rb

# termux-fix-shebang
termux-fix-shebang ${PREFIX}/opt/metasploit-framework/msfconsole
termux-fix-shebang ${PREFIX}/opt/metasploit-framework/msfvenom
termux-fix-shebang ${PREFIX}/opt/metasploit-framework/msfrpcd

# Link Metasploit Executables
ln -sf ${PREFIX}/opt/metasploit-framework/msfconsole ${PREFIX}/bin/
ln -sf ${PREFIX}/opt/metasploit-framework/msfvenom ${PREFIX}/bin/
ln -sf ${PREFIX}/opt/metasploit-framework/msfrpcd ${PREFIX}/bin/
termux-elf-cleaner ${PREFIX}/lib/ruby/gems/*/gems/pg-*/lib/pg_ext.so

echo -e "\033[32m" # Blue color
center "Installation complete"
echo -e "\nStart Metasploit using the command: msfconsole"
echo -e "\033[0m" # Reset color
