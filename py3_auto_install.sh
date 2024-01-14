#!/bin/bash
# Author: nestealin
# Created: 2022-12-11
# Update: 2023-05-13 change openssl version from 1.1.1a to 1.1.1k
# Update: 2023-09-23 promt Python and Openssl version to variables


command=$1
install_script_dir="$( cd "$( dirname "$0"  )" && pwd  )"
packages_dir="$install_script_dir/packages"

PYTHON_VERSION="3.7.11"
PYTHON_MAIN_VERSION=$(echo "$PYTHON_VERSION" | cut -d. -f1-2)
OPENSSL_VERSION="1.1.1k"


# EnvPrepare
function Setup_Install_Env() {
    yum install gcc zlib-devel make libffi-devel -y
    yum install -y ca-certificates
    [ ! -d $packages_dir ] && mkdir $packages_dir
    echo -e "\033[32mpackages directory: $packages_dir\033[0m"
}

# Download Packages
function Download_Python_Package() {
    cd $packages_dir
    tarball="Python-${PYTHON_VERSION}.tar.xz"
    if [ ! -f $tarball ]; then
        echo "Downloading $tarball"
        wget https://www.python.org/ftp/python/${PYTHON_VERSION}/$tarball
    [ ! -f $tarball ] && echo -e "\033[31mfail to download $tarball\033[0m" && exit 1
    fi
}


function Download_Openssl_Packages() {
    cd $packages_dir
    tarball="openssl-${OPENSSL_VERSION}.tar.gz"
    if [ ! -f $tarball ]; then
        echo "Downloading $tarball"
        wget https://www.openssl.org/source/$tarball
        echo "Downloading cacert.pem"
        wget http://curl.haxx.se/ca/cacert.pem
    [ ! -f $tarball ] && echo -e "\033[31mfail to download $tarball\033[0m" && exit 1
    fi
}

function Download_Pip3_Package() {
    cd $packages_dir
    tarball="ez_setup.py"
    if [ ! -f $tarball ]; then
        echo "Downloading $tarball"
        wget https://bootstrap.pypa.io/$tarball --no-check-certificate
    [ ! -f $tarball ] && echo -e "\033[31mfail to download $tarball\033[0m" && exit 1
    fi
}

function Install_Openssl() {
    install_dir="/usr/local/openssl-${OPENSSL_VERSION}"
    cd $packages_dir
    tarball="openssl-${OPENSSL_VERSION}.tar.gz"
    tar -zxvf $tarball
    cd openssl-${OPENSSL_VERSION}
    ./config --prefix=$install_dir --openssldir=$install_dir
    make -j `cat /proc/cpuinfo | grep -i name | wc -l` && make install
    if [ -d $install_dir ]; then
        mv $packages_dir/cacert.pem /usr/local/openssl-${OPENSSL_VERSION}/cert.pem
        echo "/usr/local/openssl-${OPENSSL_VERSION}/lib" > /etc/ld.so.conf.d/openssl-${OPENSSL_VERSION}-x86_64.conf
        ldconfig
    [ ! -d $install_dir ] && echo -e "\033[31mfail to install $install_dir\033[0m" && exit 1
    fi
}

function Install_Python3() {
    install_dir="/usr/local/python-${PYTHON_VERSION}"
    openssl_dir="/usr/local/openssl-${OPENSSL_VERSION}"
    cd $packages_dir
    tar xvf Python-${PYTHON_VERSION}.tar.xz
    cd Python-${PYTHON_VERSION}
    ./configure --prefix=/usr/local/python-${PYTHON_VERSION} --enable-optimizations --with-openssl=$openssl_dir
    make -j `cat /proc/cpuinfo | grep -i name | wc -l` && make install
    if [ -d $install_dir ]; then
        ln -s /usr/local/python-${PYTHON_VERSION} /usr/local/python3
        ln -s /usr/local/python-${PYTHON_VERSION}/bin/python${PYTHON_MAIN_VERSION} /usr/bin/python3
        ln -s /usr/local/python-${PYTHON_VERSION}/bin/pip3 /usr/bin/pip3
    [ ! -d $install_dir ] && echo -e "\033[31mfail to install $install_dir\033[0m" && exit 1
    fi
}

function Install_Pip3() {
    install_dir="/usr/local/python-${PYTHON_VERSION}/bin"
    cd $packages_dir
    if [ -d $install_dir ]; then
        $install_dir/python3 ez_setup.py
    [ ! -d $install_dir ] && echo -e "\033[31mfail to install $install_dir\033[0m" && exit 1
    fi
}

function Install_Virtualenv() {
    install_dir="/usr/local/python-${PYTHON_VERSION}/bin"
    if [ -d $install_dir ]; then
        $install_dir/pip3 install virtualenv virtualenvwrapper
    [ ! -d $install_dir ] && echo -e "\033[31mfail to install $install_dir\033[0m" && exit 1
    fi
    virtualenvwrapper_script="virtualenvwrapper.sh"
    if [ -f $install_dir/virtualenvwrapper.sh ]; then
        mkdir -p /data1/virtualpython/virtualenvs && mkdir /data1/virtualpython/PyEnv
        mkdir -p /data1/virtualpython_others/virtualenvs && mkdir /data1/virtualpython_others/PyEnv
        env=$(cat <<EOF >>~/.bashrc
# 为非root用户提供
if [ `id -u` != '0' ]; then
    export WORKON_HOME=/data1/virtualpython_others/virtualenvs
    export PROJECT_HOME=/data1/virtualpython_others/PyEnvs
    source /usr/local/python-${PYTHON_VERSION}/bin/virtualenvwrapper.sh
fi

# 如果root用户添加如下:
export WORKON_HOME=/data1/virtualpython/virtualenvs
export PROJECT_HOME=/data1/virtualpython/PyEnvs
export VIRTUALENVWRAPPER_PYTHON=/usr/local/python-${PYTHON_VERSION}/bin/python${PYTHON_MAIN_VERSION}
export VIRTUALENVWRAPPER_VIRTUALENV=/usr/local/python-${PYTHON_VERSION}/bin/virtualenv
source /usr/local/python-${PYTHON_VERSION}/bin/virtualenvwrapper.sh

EOF
)
        $env
        source ~/.bashrc

    [ ! -f $install_dir/virtualenvwrapper.sh ] && echo -e "\033[31mfail to install virtualenvwrapper.sh\033[0m" && exit 1
    fi
}

# HELP，-p|--python-only 仅安装python，默认项 , -v|--with-virtualEnv 虚拟环境
function help()
{
    echo -e "\033[31musage: $0 Options: [-d|-p] [-v]\033[0m"
    echo -e "\033[31mOPTIONS:\033[0m"
    echo -e "\033[31m    -d|-p|--python-only    install python only, Default option\033[0m"
    echo -e "\033[31m    -v|--with-virtualEnv   instal python with virtualEnv\033[0m"
}

case $command in
    (-d|-p|--python-only)
        Setup_Install_Env
        Download_Openssl_Packages
        Install_Openssl
        Download_Python_Package
        Download_Pip3_Package
        Install_Python3
        Install_Pip3
        ;;
    (-v|--with-virtualEnv)
        Setup_Install_Env
        Download_Openssl_Packages
        Install_Openssl
        Download_Python_Package
        Download_Pip3_Package
        Install_Python3
        Install_Pip3
        Install_Virtualenv
        ;;
    (-h|--help|help)
        help
        ;;
    (*)
        echo "Error command"
        help
        ;;
esac
