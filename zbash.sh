#!/usr/bin/env bash
# Initialize Bash It

# Reload Library
case $OSTYPE in
  darwin*)
    alias reload='source ~/.bash_profile'
    ;;
  *)
    alias reload='source ~/.bashrc'
    ;;
esac

# Only set $ZBASH if it's not already set
if [ -z "$ZBASH" ];
then
    # Setting $BASH to maintain backwards compatibility
    # TODO: warn users that they should upgrade their .bash_profile
    export ZBASH=$BASH
    export BASH=`bash -c 'echo $BASH'`
fi

# For backwards compatibility, look in old BASH_THEME location
if [ -z "$ZBASH_THEME" ];
then
    # TODO: warn users that they should upgrade their .bash_profile
    export ZBASH_THEME="$BASH_THEME";
    unset $BASH_THEME;
fi

# Load composure first, so we support function metadata
source "${ZBASH}/lib/composure.zbash"

# support 'plumbing' metadata
cite _about _param _example _group _author _version

# Load colors first so they can be use in base theme
source "${ZBASH}/themes/colors.theme.zbash"
source "${ZBASH}/themes/base.theme.zbash"

# library
LIB="${ZBASH}/lib/*.zbash"
for config_file in $LIB
do
  source $config_file
done

# Load enabled aliases, completion, plugins
for file_type in "aliases" "completion" "plugins"
do
  _load_ZBASH_files $file_type
done

# Load custom aliases, completion, plugins
for file_type in "aliases" "completion" "plugins"
do
  if [ -e "${ZBASH}/${file_type}/custom.${file_type}.zbash" ]
  then
    source "${ZBASH}/${file_type}/custom.${file_type}.zbash"
  fi
done

# Custom
CUSTOM="${ZBASH}/custom/*.zbash"
for config_file in $CUSTOM
do
  if [ -e "${config_file}" ]; then
    source $config_file
  fi
done

unset config_file
if [[ $PROMPT ]]; then
    export PS1="\["$PROMPT"\]"
fi

# Adding Support for other OSes
PREVIEW="less"
[ -s /usr/bin/gloobus-preview ] && PREVIEW="gloobus-preview"
[ -s /Applications/Preview.app ] && PREVIEW="/Applications/Preview.app"

# Load all the Jekyll stuff

if [ -e "$HOME/.jekyllconfig" ]
then
  . "$HOME/.jekyllconfig"
fi
