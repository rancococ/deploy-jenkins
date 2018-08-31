#!/usr/bin/env bash

set -e

# ##################################################################
# proxy settings
proxy_server=http://192.168.180.160:6969
ftp_proxy=${proxy_server}
http_proxy=${proxy_server}
https_proxy=${proxy_server}

# ##################################################################
# update /etc/profile
echo \>\>\>update /etc/profile. && \
sed -i '/ftp_proxy/d' /etc/profile && \
sed -i '/http_proxy/d' /etc/profile && \
sed -i '/https_proxy/d' /etc/profile && \
cp -f /etc/profile /etc/profile.back && \
cat << EOF >> /etc/profile
# proxy settings
ftp_proxy=${proxy_server}
http_proxy=${proxy_server}
https_proxy=${proxy_server}
export ftp_proxy
export http_proxy
export https_proxy
EOF

source /etc/profile

# ##################################################################
# update /etc/yum.conf
echo \>\>\>update /etc/yum.conf. && \
cp -f /etc/yum.conf /etc/yum.conf.back && \
cat << EOF >> /etc/yum.conf
# proxy settings
proxy=${proxy_server}
EOF

# ##################################################################
# update /etc/wgetrc
echo \>\>\>update /etc/wgetrc. && \
cp -f /etc/wgetrc /etc/wgetrc.back && \
cat << EOF >> /etc/wgetrc
# proxy settings
http_proxy=${proxy_server}
ftp_proxy=${proxy_server}
EOF

echo \>\>\>update proxy settings successful, please reboot server.

echo

exit 0
