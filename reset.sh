#!/bin/bash
set -e

navicat_plist="$HOME/Library/Preferences/com.navicat.NavicatPremium.plist"
navicat_dir="$HOME/Library/Application Support/PremiumSoft CyberTech/Navicat CC/Navicat Premium"
navicat_info="/Applications/Navicat Premium.app/Contents/Info.plist"
hash="" #如果有值则通过这个设定的值操作plist文件,没有值则通过正则匹配找出hash
echo "$(date "+%Y-%m-%d %H:%M:%S")   reset trial time RUNS"

if [ -f "$navicat_info" ]; then
    regex1="CFBundleShortVersionString = \"([^\.]+)"
    [[ $(defaults read "$navicat_info") =~ $regex1 ]]
    version=${BASH_REMATCH[1]}
    case $version in
    "17" | "16")
        echo "$(date "+%Y-%m-%d %H:%M:%S")   Detected Navicat Premium version $version"
        ;;
    *)
        echo "$(date "+%Y-%m-%d %H:%M:%S")   Version '$version' not Support"
        exit 1
        ;;
    esac
else
    # 未安装
    echo "$(date "+%Y-%m-%d %H:%M:%S")   crack FAILS : navicat_info not exists, maybe not installed"
    exit 1
fi

if [ -f "$navicat_plist" ] && [ -e "$navicat_dir" ]; then

    if [ -n "$hash" ]; then
        # hash值被预设则直接删除
        echo "$(date "+%Y-%m-%d %H:%M:%S")   delete Preset Hash : $hash"
        defaults delete "$navicat_plist" "$hash"
    else
        # 通过正则找出hash
        regex2="([0-9A-Z]{32}) = .*CCPreferences ="        #寻找'CCPreferences ='之前的32个大写字母或数字,后面有等号,子模式()中为要提取的hash值
        [[ $(defaults read "$navicat_plist") =~ $regex2 ]] #定义一个正则表达式模式来匹配 hash 值
        hash=${BASH_REMATCH[1]}                            #提取匹配到的第一个子模式，即 plist 中的 32 个大写字母或数字

        if [ -n "$hash" ]; then
            #hash值不为空则删除
            echo "$(date "+%Y-%m-%d %H:%M:%S")   delete Regex Hash : $hash"
            defaults delete "$navicat_plist" "$hash"
        else
            echo "$(date "+%Y-%m-%d %H:%M:%S")   the Regex Hash not exists!"
        fi
    fi

    # 删除文件
    delete_file=$(find "$navicat_dir" -maxdepth 1 -type f -regex "^$navicat_dir/\.[0-9A-Z]\{32\}$" -delete -print)
    if [ -n "$delete_file" ]; then
        echo "$(date "+%Y-%m-%d %H:%M:%S")   these files has deleted: "
        echo "$delete_file"
    else
        echo "$(date "+%Y-%m-%d %H:%M:%S")   the delete_file is empty, nothing to delete!"
    fi
    echo "$(date "+%Y-%m-%d %H:%M:%S")   crack SUCCESS"
else
    # 未安装或者从未打开过
    echo "$(date "+%Y-%m-%d %H:%M:%S")   crack FAILS : not installed"
fi
