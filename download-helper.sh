#!/usr/bin/env bash

##########################################################################
# download-helper.sh
# --all 下载jdk,maven,gradle
# --jdk 仅下载jdk
# --maven 仅下载maven
# --gradle 仅下载gradle
##########################################################################

set -e

#
# set author info
#
date1=`date "+%Y-%m-%d %H:%M:%S"`
date2=`date "+%Y%m%d%H%M%S"`
author="yong.ran@cdjdgm.com"

#
# envirionment
#

# jdk info
JDK_VERSION=8
JDK_UPDATE=192
JDK_BUILD=12
JDK_FILE=jdk-${JDK_VERSION}u${JDK_UPDATE}-linux-x64.tar.gz
JDK_URL=https://repo.huaweicloud.com/java/jdk/${JDK_VERSION}u${JDK_UPDATE}-b${JDK_BUILD}/jdk-${JDK_VERSION}u${JDK_UPDATE}-linux-x64.tar.gz

# maven info
MAVEN_VERSION=3.5.4
MAVEN_FILE=apache-maven-${MAVEN_VERSION}-bin.tar.gz
MAVEN_URL=https://repo.huaweicloud.com/apache/maven/maven-3/${MAVEN_VERSION}/binaries/apache-maven-${MAVEN_VERSION}-bin.tar.gz

# gradle info
GRADLE_VERSION=3.5.1
GRADLE_FILE=gradle-${GRADLE_VERSION}-bin.zip
GRADLE_URL=https://services.gradle.org/distributions/gradle-${GRADLE_VERSION}-bin.zip

# save path
SAVE_PATH=volume/jenkins/data

set -o noglob

#
# font and color 
#
bold=$(tput bold)
underline=$(tput sgr 0 1)
reset=$(tput sgr0)

red=$(tput setaf 1)
green=$(tput setaf 2)
yellow=$(tput setaf 3)
blue=$(tput setaf 4)
white=$(tput setaf 7)

#
# header and logging
#
header() { printf "\n${underline}${bold}${blue}► %s${reset}\n" "$@"; }
header2() { printf "\n${underline}${bold}${blue}♦ %s${reset}\n" "$@"; }
info() { printf "${white}➜ %s${reset}\n" "$@"; }
info2() { printf "${red}➜ %s${reset}\n" "$@"; }
warn() { printf "${yellow}➜ %s${reset}\n" "$@"; }
error() { printf "${red}✖ %s${reset}\n" "$@"; }
success() { printf "${green}✔ %s${reset}\n" "$@"; }
usage() { printf "\n${underline}${bold}${blue}Usage:${reset} ${blue}%s${reset}\n" "$@"; }

trap "error '******* ERROR: Something went wrong.*******'; exit 1" sigterm
trap "error '******* Caught sigint signal. Stopping...*******'; exit 2" sigint

set +o noglob

#
# entry base dir
#
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

#
# args flag
#
arg_help=
arg_jdk=
arg_maven=
arg_gradle=
arg_empty=true


#
# parse parameter
#
# echo $@
# 定义选项， -o 表示短选项 -a 表示支持长选项的简单模式(以 - 开头) -l 表示长选项 
# a 后没有冒号，表示没有参数
# b 后跟一个冒号，表示有一个必要参数
# c 后跟两个冒号，表示有一个可选参数(可选参数必须紧贴选项)
# -n 出错时的信息
# -- 也是一个选项，比如 要创建一个名字为 -f 的目录，会使用 mkdir -- -f ,
#    在这里用做表示最后一个选项(用以判定 while 的结束)
# $@ 从命令行取出参数列表(不能用用 $* 代替，因为 $* 将所有的参数解释成一个字符串
#                         而 $@ 是一个参数数组)
# args=`getopt -o ab:c:: -a -l apple,banana:,cherry:: -n "${source}" -- "$@"`
args=`getopt -o h -a -l help,all,jdk,maven,gradle -n "${source}" -- "$@"`
# 判定 getopt 的执行时候有错，错误信息输出到 STDERR
if [ $? != 0 ]; then
    error "Terminating..." >&2
    exit 1
fi
# echo ${args}
# 重新排列参数的顺序
# 使用eval 的目的是为了防止参数中有shell命令，被错误的扩展。
eval set -- "${args}"
# 处理具体的选项
while true
do
    case "$1" in
        -h | --help | -help)
            info "option -h|--help"
            arg_help=true
            arg_empty=false
            shift
            ;;
        --all | -all)
            info "option --all"
            arg_jdk=true
            arg_maven=true
            arg_gradle=true
            arg_empty=false
            shift
            ;;
        --jdk | -jdk)
            info "option --jdk"
            arg_jdk=true
            arg_empty=false
            shift
            ;;
        --maven | -maven)
            info "option --maven"
            arg_maven=true
            arg_empty=false
            shift
            ;;
        --gradle | -gradle)
            info "option --gradle"
            arg_gradle=true
            arg_empty=false
            shift
            ;;
        --)
            shift
            break
            ;;
        *)
            error "Internal error!"
            exit 1
            ;;
    esac
done
#显示除选项外的参数(不包含选项的参数都会排到最后)
# arg 是 getopt 内置的变量 , 里面的值，就是处理过之后的 $@(命令行传入的参数)
for arg do
   warn "$arg";
done

# show usage
usage=$"`basename $0` [-h|--help] [--all] [--jdk] [--maven] [--gradle]
       [-h|--help]          : show help info.
       [--all]              : download jdk,maven,gradle.
       [--jdk]              : download jdk.
       [--maven]            : download maven.
       [--gradle]           : download gradle.
"

# download jdk
fun_download_jdk() {
    header "download jdk:"
    info "download jdk [${JDK_VERSION}u${JDK_UPDATE}] start..."
    info "download url [${JDK_URL}]"
    wget -c -O ${base_dir}/${SAVE_PATH}/${JDK_FILE} --no-cookies --no-check-certificate --header "Cookie: oraclelicense=accept-securebackup-cookie" ${JDK_URL}
    tempname=$(tar -tf ${base_dir}/${SAVE_PATH}/${JDK_FILE} | awk -F "/" '{print $1}' | sed -n '1p')
    rm -rf ${base_dir}/${SAVE_PATH}/${tempname}
    tar -zxf ${base_dir}/${SAVE_PATH}/${JDK_FILE} -C ${base_dir}/${SAVE_PATH}
    info2 "unzip path [${base_dir}/${SAVE_PATH}/${tempname}]"
    success "download jdk [${JDK_VERSION}u${JDK_UPDATE}] success, local path is [${base_dir}/${SAVE_PATH}/${JDK_FILE}]."
    return 0
}

# download maven
fun_download_maven() {
    header "download maven:"
    info "download maven [${MAVEN_VERSION}] start..."
    info "download url [${MAVEN_URL}]"
    wget -c -O ${base_dir}/${SAVE_PATH}/${MAVEN_FILE} --no-cookies --no-check-certificate ${MAVEN_URL}
    tempname=$(tar -tf ${base_dir}/${SAVE_PATH}/${MAVEN_FILE} | awk -F "/" '{print $1}' | sed -n '1p')
    rm -rf ${base_dir}/${SAVE_PATH}/${tempname}
    tar -zxf ${base_dir}/${SAVE_PATH}/${MAVEN_FILE} -C ${base_dir}/${SAVE_PATH}
    info2 "unzip path [${base_dir}/${SAVE_PATH}/${tempname}]"
    success "download maven [${MAVEN_VERSION}] success, local path is [${base_dir}/${SAVE_PATH}/${MAVEN_FILE}]."
    return 0
}

# download gradle
fun_download_gradle() {
    header "download gradle:"
    info "download gradle [${GRADLE_VERSION}] start..."
    info "download url [${GRADLE_URL}]"
    wget -c -O ${base_dir}/${SAVE_PATH}/${GRADLE_FILE} --no-cookies --no-check-certificate ${GRADLE_URL}
    tempname=$(unzip -Z -1 ${base_dir}/${SAVE_PATH}/${GRADLE_FILE} | awk -F "/" '{print $1}' | sed -n '1p')
    rm -rf ${base_dir}/${SAVE_PATH}/${tempname}
    unzip -q ${base_dir}/${SAVE_PATH}/${GRADLE_FILE} -d ${base_dir}/${SAVE_PATH}
    info2 "unzip path [${base_dir}/${SAVE_PATH}/${tempname}]"
    success "download gradle [${GRADLE_VERSION}] success, local path is [${base_dir}/${SAVE_PATH}/${GRADLE_FILE}]."
    return 0
}


##########################################################################

# argument is empty
if [ "x${arg_empty}" == "xtrue" ]; then
    usage "$usage";
    exit 1
fi

# show usage
if [ "x${arg_help}" == "xtrue" ]; then
    usage "$usage";
    exit 1
fi

# download jdk
if [ "x${arg_jdk}" == "xtrue" ]; then
    fun_download_jdk;
fi

# download maven
if [ "x${arg_maven}" == "xtrue" ]; then
    fun_download_maven;
fi

# download gradle
if [ "x${arg_gradle}" == "xtrue" ]; then
    fun_download_gradle;
fi

success "complete."

exit $?
