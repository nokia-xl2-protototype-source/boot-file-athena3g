#!/system/bin/sh
# Copyright (c) 2013, Qualcomm Technologies, Inc. All Rights Reserved.
#
# Qualcomm Technologies Proprietary and Confidential.
#

#
# version 1.1.1
#
export PATH=/system/bin:$PATH

strBakForReplace=".bakforspec"
strExcludeFiles="exclude.list"
strExcludeFolder="exclude"
strForLink=".link"
strSpec=""
SourceFolder=""
DestFolder=""
CurrentSpec=""
BasePath=""
LocalFlag=""
BasePathLength=${#BasePath}

createFolder()
{
  local dirPath=$1
  if [ -d "$dirPath" ]
  then
    echo "Exist $dirPath"
  else
    createFolder "${dirPath%/*}"
    echo "mkdir and chmod $dirPath"
    mkdir "$dirPath"
    chmod 755 "$dirPath"
  fi
}

installFunc()
{
  local srcPath=$1
  local dstPath=$2
  local dstDir="${dstPath%/*}"
  createFolder $dstDir
  echo "installFunc $srcPath $dstPath $dstDir"
  if [ "${dstPath%$strForLink}" != "$dstPath" ]
  then
    dstPath="${dstPath%$strForLink}"
  fi
  if [ "${srcPath%$strForLink}" != "$srcPath" ]
  then
    if [ "${dstPath#${BasePath}/system/}" != "${dstPath}" ]
    then
      if [ -f "${srcPath%$strForLink}" ]
      then
        mv "${srcPath%$strForLink}" $dstPath
        chmod 644 "$dstPath"
      fi
    else
      cp -p "${srcPath%$strForLink}" $dstPath
      chmod 644 "$dstPath"
    fi
  elif [ -h "$srcPath$strForLink" ]
  then
    installFunc "$srcPath$strForLink" $dstPath
  else
    if [ -f "$dstPath" ]
    then
      if [ -f "$dstPath$strBakForReplace" ]
      then
        rm $dstPath$strBakForReplace
      fi
      mv $dstPath $dstPath$strBakForReplace
    fi
    ln -s ${dstPath#$BasePath} "$srcPath$strForLink"
    installFunc "$srcPath$strForLink" $dstPath
  fi
}

uninstallFunc()
{
  local srcPath=$1
  local dstPath=$2
  echo "uninstallFunc $srcPath $dstPath"
  if [ "${dstPath%$strForLink}" != "$dstPath" ]
  then
    dstPath="${dstPath%$strForLink}"
  fi
  if [ "${srcPath%$strForLink}" != "$srcPath" ]
  then
    if [ "${dstPath#${BasePath}/system/}" != "${dstPath}" ]
    then
      if [ -f "$dstPath" ]
      then
        if [ -f "${srcPath%$strForLink}" ]
        then
          rm $dstPath
        else
          mv $dstPath "${srcPath%$strForLink}"
          chmod 644 "${srcPath%$strForLink}"
        fi
      fi
    else
      rm $dstPath
    fi
    if [ -f "$dstPath$strBakForReplace" ]
    then
      if [ -f "$dstPath" ]
      then
        rm $dstPath
      fi
      mv $dstPath$strBakForReplace $dstPath
    fi
    rm $srcPath
  elif [ -h "$srcPath$strForLink" ]
  then
    uninstallFunc "$srcPath$strForLink" $dstPath
  else
    echo "Finish install"
  fi
}

installFolderFunc()
{
  local srcPath=$1
  local dstPath=$2
  for item in `ls -a $srcPath`
  do
    echo "find item=$item"
    if [ "$item" = "." ]
    then
      echo "current folder"
    else
      if [ "$item" = ".." ]
      then
        echo "upfolder"
      elif [ "$item" = ".preloadspec" ] || [ "$item" = "$strExcludeFiles" ]
      then
        echo "specflag"
      else
        if [ -f "$srcPath/$item" ]
        then
          installFunc "$srcPath/${item}" "$dstPath/${item}"
        elif [ -h "$srcPath/$item" ]
        then
          installFunc "$srcPath/${item}" "$dstPath/${item}"
        else
          if [ -d "$srcPath/$item" ]
          then
            installFolderFunc "$srcPath/${item}" "$dstPath/${item}"
          fi
        fi
      fi
    fi
  done
}

uninstallFolderFunc()
{
  local srcPath=$1
  local dstPath=$2
  for item in `ls -a $srcPath`
  do
    echo "uitem=$item"
    if [ "$item" = "." ]
    then
      echo "current folder"
    else
      if [ "$item" = ".." ]
      then
        echo "upfolder"
      elif [ "$item" = ".preloadspec" ] || [ "$item" = "$strExcludeFiles" ]
      then
        echo "specflag"
      else
        if [ -f "$srcPath/$item" ]
        then
          uninstallFunc "$srcPath/${item}" "$dstPath/${item}"
        elif [ -h "$srcPath/$item" ]
        then
          uninstallFunc "$srcPath/${item}" "$dstPath/${item}"
        else
          if [ -d "$srcPath/$item" ]
          then
            uninstallFolderFunc "$srcPath/${item}" "$dstPath/${item}"
          fi
        fi
      fi
    fi
  done
}

excludeFilesFunc()
{
  local srcPath=$1
  if [ -f "$srcPath" ]
  then
    echo "exclude the files in current carrier"
    while read line
    do
      if [ -f "$DestFolder/$line" ]
      then
        local dstPath="$SourceFolder/$strExcludeFolder/$line"
        local dstDir="${dstPath%/*}"
        createFolder $dstDir
        if [ "${line#system/}" != "${line}" ]
        then
          mv $DestFolder/$line $dstPath
        else
          cp -p $DestFolder/$line $dstPath
        fi
      fi
    done < "$srcPath"
  fi
}

includeFilesFunc()
{
  local srcPath=$1
  if [ -f "$srcPath" ]
  then
    echo "restore the files excluded in previous carrier"
    while read line
    do
      if [ -f "$SourceFolder/$strExcludeFolder/$line" ]
      then
        local dstPath="$DestFolder/$line"
        if [ "${line#system/}" != "${line}" ]
        then
          mv "$SourceFolder/$strExcludeFolder/$line" $dstPath
        else
          cp -p "$SourceFolder/$strExcludeFolder/$line" $dstPath
        fi
      fi
    done < "$srcPath"
  fi
}

getCurrentCarrier()
{
  local specPath=$1
  strSpec=""
  if [ -f "$specPath" ]
  then
    . $specPath
  fi
}

makeFlagFolder()
{
  if [ -d "$DestFolder/data/switch_spec" ]
  then
    echo "no need to create flag"
  else
    mkdir "$DestFolder/data/switch_spec"
    chmod 770 "$DestFolder/data/switch_spec"
  fi
}

if [ "$#" -eq "0" ]
then
  if [ -d "$DestFolder/data/switch_spec" ]
  then
    echo "check ok"
  else
    getCurrentCarrier "$DestFolder/system/vendor/speccfg/spec"
    installFolderFunc "$DestFolder/system/vendor/Default/data" "$DestFolder/data"
    if [ "$strSpec" = "" ] || [  "$strSpec" = "Default" ]
    then
      echo "not find spec or default spec"
    else
      installFolderFunc "$DestFolder/system/vendor/$strSpec/data" "$DestFolder/data"
    fi
    makeFlagFolder
  fi
else
  SourceFolder="$1"
  DestFolder="$2"
  BasePath="$3"
  LocalFlag="$4"
  SwitchFlag="$DestFolder/system/vendor/speccfg/spec.new"
  echo "SourceFolder=$SourceFolder DestFolder=$DestFolder BasePath=$BasePath LocalFlag=$LocalFlag"
  RmFlag="0"
  if [ -d "$SourceFolder/$strExcludeFolder" ]
  then
    echo "no need to create excludefolder"
  else
    mkdir "$SourceFolder/$strExcludeFolder"
    chmod 770 "$SourceFolder/$strExcludeFolder"
  fi
  if [ "$#" -gt "4" ]
  then
    CurrentSpec="$5"
  else
    SwitchApp="$DestFolder/data/data/com.qualcomm.qti.featuresettings"
    if [ -f "$SwitchApp/cache/action" ]
    then
      cp -rf "$SwitchApp/cache/action" "$SwitchFlag"
    fi
    if [ -f "$SwitchFlag" ]
    then
      . "$SwitchFlag"
      CurrentSpec="$strNewSpec"
    fi
    if [ "$CurrentSpec" = "" ]
    then
      CurrentSpec="Default"
    fi
    if [ -f "$SwitchApp/cache/rmflag" ]
    then
      RmFlag="1"
    fi
    wipe data
  fi
  BasePathLength=${#BasePath}
  getCurrentCarrier "$LocalFlag"
  if [ "${#strSpec}" -eq "0" ]
  then
    echo "No find carrier, but need to install Default"
    if [ "${CurrentSpec}" != "Default" ]
    then
      installFolderFunc "$SourceFolder/Default" "$DestFolder"
    fi
  else
    if [ "${strSpec}" = "Default" ]
    then
      echo "Default spec no need to back, but need to recover the data partition for wipe!"
      installFolderFunc "$SourceFolder/Default/data" "$DestFolder/data"
    else
      uninstallFolderFunc "$SourceFolder/$strSpec" "$DestFolder"
      includeFilesFunc "$SourceFolder/$strSpec/$strExcludeFiles"
    fi
    if [ "$RmFlag" -eq "1" ]
    then
      rm -rf "$SourceFolder/$strSpec"
    fi
  fi
  echo "CurrentSpec=$CurrentSpec"
  rm -rf $SourceFolder/$strExcludeFolder/*
  excludeFilesFunc "$SourceFolder/$CurrentSpec/$strExcludeFiles"
  installFolderFunc "$SourceFolder/$CurrentSpec" "$DestFolder"
  echo "strSpec=$CurrentSpec" > "$LocalFlag"
  chmod 644 "$LocalFlag"
fi

makeFlagFolder

if [ -f "$DestFolder/system/vendor/speccfg/spec.new" ]
then
  rm -rf "$DestFolder/system/vendor/speccfg/spec.new"
fi
