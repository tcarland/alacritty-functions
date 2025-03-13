# ----------------------------------------
#  Alacritty Terminal Profiles handling
#
#  Timothy C. Arland <tcarland@gmail.com>
#
export ALACRITTY_FUNCTIONS_VERSION="v25.03.13"
export ALACRITTY_CONFIG_HOME="${HOME}/.config/alacritty"

export ALACRITTY_CONFIG_TEMPLATE="${ALACRITTY_CONFIG_HOME}/alacritty-template.toml"
export ALACRITTY_PROFILE_NAME="${ALACRITTY_PROFILE_NAME:-default}"
export ALACRITTY_CONFIG="${ALACRITTY_CONFIG_HOME}/alacritty-${ALACRITTY_PROFILE_NAME}.toml"

export C_NC='\e[0m'
export C_GRN='\e[32m\e[1m'
export C_CYN='\e[96m'


function critty_functions_list()
{
    declare -F | awk '{ print $NF }' | sort | egrep -v "^_" | grep "^critty"
}


function critty_new()
{
    local name="${1:-default}"
    local config="${ALACRITTY_CONFIG_HOME}/alacritty-${name}.toml"

    if [ -z "$name" ]; then
        printf "critty_new() requires profile name \n" >&2
        return 1
    fi

    ( ALACRITTY_PROFILE_NAME="$name" critty_config $config && \
      ALACRITTY_PROFILE_NAME="$name" alacritty --config-file $config >/dev/null 2>&1 & )
    
    return $?
}


function critty_config()
{
    local config="${1:-${ALACRITTY_CONFIG}}"
    local name="${ALACRITTY_PROFILE_NAME:-default}"
    local rt=0

    if [ "$name" == "default" ]; then
        config="${ALACRITTY_CONFIG_HOME}/alacritty.toml"
    fi

    if [ -z "$config" ]; then
        config="${ALACRITTY_CONFIG_HOME}/alacritty-${name}.toml"
    fi
    if [[ ! -f $config ]]; then
        cat "${ALACRITTY_CONFIG_TEMPLATE}" 2>/dev/null | envsubst > $config
    fi

    printf "%s\n" $config
    if [[ ! -r "$config" ]]; then
        rt=1
    fi

    return $rt
}


function critty_profiles()
{
    local name=
    local profiles=$(ls -1 ${ALACRITTY_CONFIG_HOME}/alacritty-* | \
      grep -v 'template' | \
      grep -v 'bak')

    printf "${C_GRN}Alacritty Profiles: ${C_NC} \n"

    if [ -e ${ALACRITTY_CONFIG_HOME}/alacritty.toml ]; then
        printf " - ${C_CYN}default${C_NC} \n"
    fi

    for profile in $profiles; do
        name="${profile##*/}"
        name="${name%.*}"
        name="${name##*-}"
        printf " - ${C_CYN}$name${C_NC} \n"
    done

    printf "${C_GRN}Current Profile: ${C_NC} \n"
    printf " - ${C_CYN}${ALACRITTY_PROFILE_NAME}${C_NC} \n"

    return 0
}


function critty_version()
{
    printf "ALACRITTY_FUNCTIONS_VERSION=$ALACRITTY_FUNCTIONS_VERSION \n"
    ( alacritty --version )
}


function critty_theme()
{
    local theme="$1"
    local config="$(critty_config)"
    local line=

    if [ -n "$theme" ]; then
        if [[ ! -e ${ALACRITTY_CONFIG_HOME}/themes/$theme.toml ]]; then
            printf "${C_RED}ERROR${C_NC} alacritty theme not found for '$theme' \n"
            return 1
        fi
        sed -i.bak "s/import \(.*\/\)[^/]*$/import \1${theme}.toml\" \]/" $config
    fi

    if [ -r $config ]; then
        theme=$(cat ${config} | grep 'themes')
        theme="${theme##*/}"
        theme="${theme%.*}"
        printf " critty: ${C_GRN}$theme${C_NC} \n"
    fi

    return 0
}


function critty_themes()
{
    printf "${C_GRN}Alacritty Themes: ${C_NC} \n"
    for theme in $(ls -1 ${ALACRITTY_CONFIG_HOME}/themes/); do
        name="${theme##*/}"
        name="${name%.*}"
        printf " - ${C_CYN}$name${C_NC} \n"
    done

    return 0
}


function critty_font()
{
    local size=$1
    local config="$(critty_config)"

    if [[ -n $size && $size -gt 0 ]]; then
        sed -i.bak "s/size = \(.*\)*$/size = $size/" $config
    fi

    if [ -r $config ]; then
        sz=$(cat $config | grep 'size =' | awk '{ print $3 }')
        printf " critty font size: $sz  \n"
    fi

    return 0
} 
           

function critty_opac()
{
    local opac=$1
    local config="$(critty_config)"

    if [ -n "$opac" ]; then
        sed -i.bak "s/opacity = \(.*\)$/opacity = $opac/" $config
    fi

    if [ -r $config ]; then
        opac=$(cat $config | grep 'opacity =' | awk '{ print $3 }')
        printf " critty opacity: $opac > \n"
    fi

    return 0
}


function critty_win()
{
    local col="$1"
    local row="$2"
    local config=$(critty_config)

    if [[ $col -gt 0 && $row -gt 0 ]]; then
        echo "Setting Alacritty window dimensions to $col x $row"
        sed -i.bak "s/dimensions = \(.*\)$/dimensions = { columns=${col}, lines=${row} }/" $config
    else
        col=$(cat $config | grep 'dimensions =' | sed -n 's/.*columns=\([0-9]*\).*/\1/p')
        row=$(cat $config | grep 'dimensions =' | sed -n 's/.*lines=\([0-9]*\).*/\1/p')
        printf " critty window  columns: $col  rows: $row \n"
    fi

    return 0
}


function crittysmall()
{
    critty_win 75 32
}

function crittylarge()
{
    critty_win 105 48
}

function crittylite() 
{
    critty_theme "solarized_light"
    critty_font 10
    critty_opac 0.99
}

function crittydark()
{
    critty_theme "ubuntu"
    critty_font 9
    critty_opac 0.8
}

function crittypro()
{
    critty_theme "monokai_pro"
    critty_font 9
    critty_opac 0.90
}

# alacritty_functions.sh
