#!/bin/bash

source scripts/utils.sh

# mock install by using `./install <mock-folder>`

targetFolder=$1
[ "$targetFolder" == "" ] && targetFolder=$HOME

if [[ "$targetFolder" = /* ]]; then
  target=$targetFolder
else
  target="$(pwd)/$targetFolder"
fi

function dotMain {

  if [ ! -d $target ]; then
    mkdir $target || exit 1
  fi

  # create useful folders
  createFolderIfNeeded git
  createFolderIfNeeded .config
  createFolderIfNeeded .local/share

  # install fonts
  safeLn "../../dotfiles/assets/fonts" ".local/share/fonts"

  # clone useful repos
  cloneRepo https://github.com/zsh-users/zsh-syntax-highlighting.git

  # bin
  safeLn "dotfiles/bin" "bin"

  for f in config/*; do
    safeLn "../dotfiles/$f" ".config/$(basename $f)"
  done

  # dotfiles
  for f in dot/*; do
    safeLn "dotfiles/$f" ".$(basename $f)"
  done

  # gpg config
  if [ -d "$target/.gnupg" ]; then
    echo "pinentry-program /usr/bin/pinentry-curses" > "$target/.gnupg/gpg-agent.conf"
  fi

  LOG "Success!" success

}

function safeLn {

  lnTarget=$1
  lnName=$2

  pushd $target >/dev/null

  if [ -L "$lnName" ]; then
    lnDest=$(readlink $lnName)
    if [ "$lnDest" != "$lnTarget" ]; then
      echo "[warning] $target/$lnName is pointing the wrong destination ($lnDest)"
      read -p "> Overwrite? (y/n) " -n 1 -r
      echo
      if [[ $REPLY == "y" ]]
      then
        ln -sf "$lnTarget" "$lnName"
        [ $? -eq 0 ] && LOG "installed $lnName"
      fi
    fi
  elif [ -e "$lnName" ]; then
    LOG "[warning] $target/$lnName exists and is not a symlink"
    read -p "> Remove? (y/n) " -n 1 -r
    echo
    if [[ $REPLY == "y" ]]
    then
      rm -rf $lnName
      ln -s "$lnTarget" "$lnName"
      [ $? -eq 0 ] && LOG "installed $lnName"
    fi
  else
    ln -s "$lnTarget" "$lnName"
    [ $? -eq 0 ] && LOG "installed $lnName"
  fi

  popd >/dev/null

}

function createFolderIfNeeded {

  pushd $target >/dev/null

  folderName=$1

  if [ ! -d "$folderName" ]; then
    LOG "creating $folderName folder"
    mkdir -p $folderName || exit 1
  fi

  popd >/dev/null

}

function cloneRepo {

  pushd $target/git >/dev/null

  repoName=$1
  folderName="$(echo $repoName | sed -E 's/.*\/([^/]*).git$/\1/g')"

  if [ ! -d "$folderName" ]; then
    LOG "installing ${folderName}..."
    git clone $repoName
  fi

  popd >/dev/null

}

dotMain
