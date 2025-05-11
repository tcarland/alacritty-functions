# ----------------------------------------
#  Alacritty Terminal Profiles handling
#
#  Timothy C. Arland <tcarland@gmail.com>
#
export ALACRITTY_FUNCTIONS_VERSION="v25.05.12"
export ALACRITTY_CONFIG_HOME="${HOME}/.config/alacritty"

export ALACRITTY_CONFIG_TEMPLATE="${ALACRITTY_CONFIG_HOME}/alacritty-template.toml"
export ALACRITTY_PROFILE_NAME="${ALACRITTY_PROFILE_NAME:-default}"
export ALACRITTY_STYLE_CONFIG="${ALACRITTY_CONFIG_HOME}/alacritty_styles.json"
export ALACRITTY_CONFIG="${ALACRITTY_CONFIG_HOME}/alacritty-${ALACRITTY_PROFILE_NAME}.toml"

export C_NC='\e[0m'
export C_GRN='\e[32m\e[1m'
export C_CYN='\e[96m'


function critty_functions_list()
{
    declare -F | awk '{ print $NF }' | sort | egrep -v "^_" | grep "^critty" | sort
}


function critty_new()
{
    local name="${1:-default}"
    local config="${ALACRITTY_CONFIG_HOME}/alacritty-${name}.toml"

    config=$(ALACRITTY_PROFILE_NAME="$name" critty_config $config)

    ( ALACRITTY_PROFILE_NAME="$name" alacritty --config-file $config >/dev/null 2>&1 & )

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
        if [[ "$theme" == "null" ]]; then
            return 1
        fi
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

    if [[ -n "$size" && $size -gt 0 ]]; then
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
        if [[ "$opac" == "null" ]]; then
            return 1
        fi
        sed -i.bak "s/opacity = \(.*\)$/opacity = $opac/" $config
    fi

    if [ -r $config ]; then
        opac=$(cat $config | grep 'opacity =' | awk '{ print $3 }')
        printf " critty opacity: $opac \n"
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


function critty_set_style()
{
    local name="$1"
    local theme="$2"
    local size=$3
    local opac=$4

    if [[ -z "$name" || -z "$theme" ]]; then
        echo "critty_set_style <name> <theme> <font_size> <opacity>"
        echo "  where name is one of 'pro', 'dark', or 'lite'"
        echo "  eg. critty_set_style pro oxocarbon 10 0.9"
        return 1
    fi

    json=$(jq ".alacritty_styles.${name}.theme = \"$theme\"" $ALACRITTY_STYLE_CONFIG)
    echo "$json" > $ALACRITTY_STYLE_CONFIG

    if [ -n "$size" ]; then
        json=$(jq ".alacritty_styles.$name.font_size = $size" $ALACRITTY_STYLE_CONFIG)
        echo "$json" > $ALACRITTY_STYLE_CONFIG
    fi

    if [ -n "$opac" ]; then
        json=$(jq ".alacritty_styles.${name}.opacity = $opac" $ALACRITTY_STYLE_CONFIG)
        echo "$json" > $ALACRITTY_STYLE_CONFIG
    fi

    return 0
}


function critty_styles()
{
    echo "Alacritty Styles:"
    styles=$(jq -r '.alacritty_styles | keys[]' $ALACRITTY_STYLE_CONFIG)
    printf "  ${C_GRN}%08s     %18s${C_NC}     [fontsz]  [opacity] \n" "<style>" "<theme>"
    for s in $styles; do
        style=$(jq -r ".alacritty_styles.$s" $ALACRITTY_STYLE_CONFIG)
        printf " ${C_CYN}%08s      %18s${C_NC}        %02d      %.2f \n" $s \
          $(echo "$style" | jq -r '.theme' -) \
          $(echo "$style" | jq -r '.font_size' -) \
          $(echo "$style" | jq -r '.opacity' -)
    done
}


function critty_style()
{
    local name="$1"

    if [ -z "$name" ]; then
        echo "Usage: critty_style() <name>"
        critty_styles
        return 0
    fi

    style=$(jq -r ".alacritty_styles.$name" $ALACRITTY_STYLE_CONFIG)

    if [[ "$style" == "null" ]]; then
        echo "critty_style '$style' not found"
        return 1
    fi

    theme=$(echo "$style" | jq -r '.theme' -)
    fontsz=$(echo "$style" | jq -r '.font_size' -)
    opac=$(echo "$style" | jq -r '.opacity' -)

    critty_theme "$theme"
    critty_font $font_sz
    critty_opac $opac

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
    critty_style "lite"
    return $?
}

function crittydark()
{
    critty_style "dark"
    return $?
}

function crittypro()
{
    critty_style "pro"
    return $?
}

# alacritty_functions.sh
