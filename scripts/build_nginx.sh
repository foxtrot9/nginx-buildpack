#!/bin/sh
#
# pcre - HTTP rewrite module requires the PCRE library. set of functions that implement regular expression pattern matching (likely not used)
# openssl - ngx_http_ssl_module (likely not used)
# misc - base64 encoding and decoding (set_decode_base64)
# headers-more - more_clear_headers, more_clear_input_headers
# ngx_devel_kit - require to build nginx
#

NGINX_VERSION=1.16.1
PCRE_VERSION=8.38
OPENSSL_VERSION=1.0.2g
SET_MISC_VERSION=${SET_MISC_VERSION-0.28}
NGX_DEVEL_KIT_VERSION=${NGX_DEVEL_KIT_VERSION-0.2.19}
MORE_CLEAR_HEADERS=${MORE_CLEAR_HEADERS-0.33}

nginx_tarball_url=http://nginx.org/download/nginx-${NGINX_VERSION}.tar.gz
pcre_tarball_url=https://ftp.pcre.org/pub/pcre/pcre-${PCRE_VERSION}.tar.gz
openssl_tarball_url=http://www.openssl.org/source/openssl-${OPENSSL_VERSION}.tar.gz
set_misc_tarball_url=https://github.com/openresty/set-misc-nginx-module/archive/v${SET_MISC_VERSION}.tar.gz
headers_more_nginx_module=https://github.com/openresty/headers-more-nginx-module/archive/v${MORE_CLEAR_HEADERS}.tar.gz
ngx_devel_kit_url=https://github.com/simpl/ngx_devel_kit/archive/v${NGX_DEVEL_KIT_VERSION}.tar.gz

temp_dir=$(mktemp -d /tmp/nginx.XXXXXXXXXX)

cleanup() {
  echo "Cleaning up $temp_dir"
  rm -rf "$temp_dir"
}
trap cleanup EXIT

binary_dir="/usr/local/nginx"
mkdir -p ${binary_dir}
script_dir=$(cd $(dirname $0); pwd)
untarring_dir=$temp_dir/untarring
nginx_binary_drop_dir=$script_dir/../bin
echo ${nginx_binary_drop_dir}

cd $temp_dir
echo "Temp dir: $temp_dir"

echo "Downloading $nginx_tarball_url"
wget $nginx_tarball_url && tar xzf nginx-${NGINX_VERSION}.tar.gz

echo "Downloading $pcre_tarball_url"
cd nginx-${NGINX_VERSION}
wget $pcre_tarball_url && tar xzf pcre-${PCRE_VERSION}.tar.gz

echo "Downloading $openssl_tarball_url"
(wget $openssl_tarball_url && tar xfz openssl-${OPENSSL_VERSION}.tar.gz)

echo "Downloading $set_misc_tarball_url"
(wget $set_misc_tarball_url && tar xfz v${SET_MISC_VERSION}.tar.gz )

echo "Downloading $headers_more_nginx_module"
(wget $headers_more_nginx_module && tar xfz v${MORE_CLEAR_HEADERS}.tar.gz)

echo "Downloading $ngx_devel_kit_url"
(wget $ngx_devel_kit_url && tar xfz v${NGX_DEVEL_KIT_VERSION}.tar.gz)

(
  ./configure --with-http_ssl_module --with-openssl=openssl-${OPENSSL_VERSION} --with-pcre=pcre-${PCRE_VERSION} --add-module=ngx_devel_kit-${NGX_DEVEL_KIT_VERSION}	--add-module=set-misc-nginx-module-${SET_MISC_VERSION} --add-module=headers-more-nginx-module-${MORE_CLEAR_HEADERS} --prefix=${binary_dir} && make install
)

mkdir -p ${nginx_binary_drop_dir}
cp ${binary_dir}/sbin/nginx ${nginx_binary_drop_dir}/
echo "Copied the nginx binary into ${nginx_binary_drop_dir}"
