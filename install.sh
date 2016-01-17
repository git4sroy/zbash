#!/usr/bin/env bash
ZBASH="$(cd "$(dirname "$0")" && pwd)"

case $OSTYPE in
  darwin*)
    CONFIG_FILE=.bash_profile
    ;;
  *)
    CONFIG_FILE=.bashrc
    ;;
esac

BACKUP_FILE=$CONFIG_FILE.bak

if [ -e "$HOME/$BACKUP_FILE" ]; then
    echo -e "\033[0;33mBackup file already exists $HOME/$BACKUP_FILE . Make sure to backup your .bashrc before running this installation.\033[0m" >&2
    while true
    do
        read -e -n 1 -r -p "Would you like to overwrite the existing backup? This will delete your existing backup file ($HOME/$BACKUP_FILE) [y/N] " RESP
        case $RESP in
        [yY])
            break
            ;;
        [nN]|"")
            echo -e "\033[91mInstallation aborted. Please come back soon!\033[m"
            exit 1
            ;;
        *)
            echo -e "\033[91mPlease choose y or n.\033[m"
            ;;
        esac
    done
fi

test -w "$HOME/$CONFIG_FILE" &&
  cp -a "$HOME/$CONFIG_FILE" "$HOME/$CONFIG_FILE.bak" &&
  echo -e "\033[0;32mYour original $CONFIG_FILE has been backed up to $CONFIG_FILE.bak\033[0m"

sed "s|{{ZBASH}}|$ZBASH|" "$ZBASH/template/bash_profile.template.zbash" > "$HOME/$CONFIG_FILE"

echo -e "\033[0;32mCopied the template $CONFIG_FILE into ~/$CONFIG_FILE, edit this file to customize zbash\033[0m"

function load_one() {
  file_type=$1
  file_to_enable=$2
  mkdir -p "$ZBASH/${file_type}/enabled"

  dest="${ZBASH}/${file_type}/enabled/${file_to_enable}"
  if [ ! -e "${dest}" ]; then
      ln -sf "../available/${file_to_enable}" "${dest}"
  else
      echo "File ${dest} exists, skipping"
  fi
}

function load_some() {
  file_type=$1
  [ -d "$ZBASH/$file_type/enabled" ] || mkdir "$ZBASH/$file_type/enabled"
  for path in `ls $ZBASH/${file_type}/available/[^_]*`
  do
    file_name=$(basename "$path")
    while true
    do
      read -e -n 1 -p "Would you like to enable the ${file_name%%.*} $file_type? [y/N] " RESP
      case $RESP in
      [yY])
        ln -s "../available/${file_name}" "$ZBASH/$file_type/enabled"
        break
        ;;
      [nN]|"")
        break
        ;;
      *)
        echo -e "\033[91mPlease choose y or n.\033[m"
        ;;
      esac
    done
  done
}

if [[ "$1" == "--interactive" ]]
then
  for type in "aliases" "plugins" "completion"
  do
    echo -e "\033[0;32mEnabling $type\033[0m"
    load_some $type
  done
else
  echo ""
  echo -e "\033[0;32mEnabling sane defaults\033[0m"
  load_one completion zbash.completion.zbash
  load_one plugins alias-completion.plugin.zbash
  load_one aliases general.aliases.zbash
fi

echo ""
echo -e "\033[0;32mInstallation finished successfully! Enjoy zbash!\033[0m"
echo -e "\033[0;32mTo start using it, open a new tab or 'source "$HOME/$CONFIG_FILE"'.\033[0m"
echo ""
echo "To show the available aliases/completions/plugins, type one of the following:"
echo "  zbash show aliases"
echo "  zbash show completions"
echo "  zbash show plugins"
echo ""
echo "To avoid issues and to keep your shell lean, please enable only features you really want to use."
echo "Enabling everything can lead to issues."
