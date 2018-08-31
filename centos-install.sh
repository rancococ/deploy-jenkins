#!/usr/bin/env bash

set -e

# ##################################################################
# proxy settings
http_proxy=http://192.168.180.160:6969

# repo urls
centos_ver=7
centos_repo=https://mirrors.aliyun.com/repo/Centos-${centos_ver}.repo
epel_repo=https://mirrors.aliyun.com/repo/epel-${centos_ver}.repo
docker_repo=https://mirrors.aliyun.com/docker-ce/linux/centos/docker-ce.repo

# gps urls
centos_gpg=https://mirrors.aliyun.com/centos/RPM-GPG-KEY-CentOS-${centos_ver}
epel_gpg=https://mirrors.aliyun.com/epel/RPM-GPG-KEY-EPEL-${centos_ver}
docker_gpg=https://mirrors.aliyun.com/docker-ce/linux/centos/gpg

# compose
compose_ver=1.22.0
compose_url=https://github.com/docker/compose/releases/download/${compose_ver}/docker-compose-$(uname -s)-$(uname -m)

# ##################################################################
# set envirionment
PWD=`pwd`
BASE_DIR="${PWD}"
SOURCE="$0"
while [ -h "$SOURCE"  ]; do
BASE_DIR="$( cd -P "$( dirname "$SOURCE"  )" && pwd  )"
SOURCE="$(readlink "$SOURCE")"
[[ $SOURCE != /*  ]] && SOURCE="$BASE_DIR/$SOURCE"
done
BASE_DIR="$( cd -P "$( dirname "$SOURCE"  )" && pwd  )"
cd $BASE_DIR

# ##################################################################
# update hosts for github and amazonaws
echo \>\>\>update hosts for github and amazonaws. && \
sed -i '/github/d' /etc/hosts && \
sed -i '/amazonaws/d' /etc/hosts && \
sed -i '/github.com/d' /etc/hosts && \
sed -i '/codeload.github.com/d' /etc/hosts && \
sed -i '/assets-cdn.github.com/d' /etc/hosts && \
sed -i '/github.global.ssl.fastly.net/d' /etc/hosts && \
sed -i '/s3.amazonaws.com/d' /etc/hosts && \
sed -i '/github-cloud.s3.amazonaws.com/d' /etc/hosts

cat << EOF >> /etc/hosts
# github and amazonaws
192.30.253.112 github.com
192.30.253.113 github.com
192.30.253.120 codeload.github.com
192.30.253.121 codeload.github.com
151.101.72.133 assets-cdn.github.com
151.101.76.133 assets-cdn.github.com
151.101.73.194 github.global.ssl.fastly.net
151.101.77.194 github.global.ssl.fastly.net
219.76.4.4 s3.amazonaws.com
219.76.4.4 github-cloud.s3.amazonaws.com
EOF

echo

# ##################################################################
# generate /etc/yum.temp.conf
echo \>\>\>generate /etc/yum.temp.conf. && \
cp -f /etc/yum.conf /etc/yum.temp.conf && \
if [ "x${http_proxy}" != "x" ]; then
cat << EOF >> /etc/yum.temp.conf;
# proxy settings
proxy=${http_proxy}
EOF
fi

echo

# ##################################################################
# install repositories and packages
echo \>\>\>install repositories and packages. && \
echo \>\>\>download repos for centos, epel, docker && \
rm -rf /etc/yum.repos.d/*.repo && \
curl -L -o /etc/yum.repos.d/centos.repo ${centos_repo} && \
curl -L -o /etc/yum.repos.d/epel.repo ${epel_repo} && \
curl -L -o /etc/yum.repos.d/docker.repo ${docker_repo} && \
sed -i '/mirrors.aliyuncs.com/d' /etc/yum.repos.d/centos.repo && \
sed -i '/mirrors.cloud.aliyuncs.com/d' /etc/yum.repos.d/centos.repo && \
yum -c /etc/yum.temp.conf clean all && \
yum -c /etc/yum.temp.conf makecache && \
rm -rf /etc/pki/rpm-gpg/* && \
echo && \
echo \>\>\>download rpm-gpg for centos, epel, docker && \
curl -L -o /etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-${centos_ver} ${centos_gpg} && \
curl -L -o /etc/pki/rpm-gpg/RPM-GPG-KEY-EPEL-${centos_ver} ${epel_gpg} && \
curl -L -o /etc/pki/rpm-gpg/RPM-GPG-KEY-DOCKER-CE ${docker_gpg} && \
echo && \
echo \>\>\>import rpm-gpg for centos, epel, docker && \
rpm --import /etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-${centos_ver} && \
rpm --import /etc/pki/rpm-gpg/RPM-GPG-KEY-EPEL-${centos_ver} && \
rpm --import /etc/pki/rpm-gpg/RPM-GPG-KEY-DOCKER-CE && \
echo && \
echo \>\>\>install packages for passwd openssl wget net-tools gettext zip unzip && \
yum -c /etc/yum.temp.conf install -y passwd openssl wget net-tools gettext zip unzip && \
yum -c /etc/yum.temp.conf clean all

echo

# ##################################################################
# install docker-compose
echo \>\>\>install docker-compose from "${compose_url}" && \
curl -L -o /usr/local/bin/docker-compose "${compose_url}" && \
chmod +x /usr/local/bin/docker-compose && \
echo && \
echo \<\<\<install successful.

exit 0
