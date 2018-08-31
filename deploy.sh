#!/bin/bash

##########################################################################
#
# deploy.sh
#
##########################################################################

set -e

# set echo color
color_red='\033[0;31m'
color_green='\033[0;32m'
color_yellow='\033[0;33m'
color_blue='\033[0;34m'
color_end='\033[0m'

# fun echo color
fun_echo_red() {
    echo -e "${color_red}$@${color_end}"
}
fun_echo_green() {
    echo -e "${color_green}$@${color_end}"
}
fun_echo_yellow() {
    echo -e "${color_yellow}$@${color_end}"
}
fun_echo_blue() {
    echo -e "${color_blue}$@${color_end}"
}
trap "fun_echo_red '******* ERROR: Something went wrong.*******'; exit 1" sigterm
trap "fun_echo_red '******* Caught sigint signal. Stopping...*******'; exit 2" sigint

# set author info
date1=`date "+%Y-%m-%d %H:%M:%S"`
date2=`date "+%Y%m%d%H%M%S"`
author="yong.ran@cdjdgm.com"


# entry base dir
pwd=`pwd`
base_dir="${pwd}"
source="$0"
while [ -h "$source" ]; do
    base_dir="$( cd -P "$( dirname "$source" )" && pwd )"
    source="$(readlink "$source")"
    [[ $source != /* ]] && source="$base_dir/$source"
done
base_dir="$( cd -P "$( dirname "$source" )" && pwd )"
cd ${base_dir}

# set docker info
image_local=""

# result code
re_err=1
re_ok=0

# #########################################GET OPTION PARAM#########################################
fun_usage() {
    fun_echo_yellow "Usage: `basename $0` [-l] [-h]"
    fun_echo_yellow "        [-l]          : load images from local tar archive file, default is false/empty."
    exit $re_err
}
while getopts lh option
do
    case $option in
        l)
            image_local=true
            ;;
        h)
            fun_usage
            ;;
        \?)
            fun_usage
            ;;
    esac
done

# #########################################FUNCTION#########################################
fun_log_echo() {
    l_arg=$1
    l_bs=`basename $0`
    l_time=`date "+%Y-%m-%d %H:%M:%S"`
    #echo "[$l_time]:[$l_bs]:$l_arg" >> "$LOG_FILE_NAME"
    fun_echo_green "$l_arg"
    return $re_ok
}

# #########################################DO FUNCTION#########################################

if [ "${image_local}" = "true" ]; then
    # import images
    docker load -i "${base_dir}/images/base.img"
fi

# deploy
chmod +x ${base_dir}/*.sh
chmod 777 ${base_dir}/volume/jenkins/data
chmod 777 ${base_dir}/volume/jenkins/pref

fun_log_echo "deploy complete."
fun_log_echo ""

exit $?
