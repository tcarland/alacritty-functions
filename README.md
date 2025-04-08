Alacritty Functions v25.04.08
=============================

Provides an Ansible role and additional *Bash* functions for installing
and managing [Alacritty](https://github.com/alacritty/alacritty)
terminals on Debian Linux-based hosts or MacOS (untested).

The *Bash* functions included offers additional functionality for creating
and managing profiles by defining multiple Alacritty configurations. This
allows for the real-time adjustment of various Alacritty features such as
themes, window opacity, and font sizes for an individual *profile*.


## Requirements

It is recommended, given the version nightmare that is Ansible, that a
Python virtual environment or *venv* is used to install Ansible. This may
require the *python3-venv* and *python3-pip* distribution packages.
```sh
python3 -m venv pyenv
source ./pyenv/bin/activate
pip install -r requirements.txt
```

- Ansible 8.5.0+ is the required minimum to install the Alacritty playbook,
  latest recommended and tested version is **v9.3.0**.
- The Bash functions require Bash 4+, with Bash 5+ being fairly standard
  on modern linux distributions.


## Installation

Given the direct nature of the playbook, an inventory file is not necessary;
A hosts list can be provided directly to *ansible-playbook*. Note that to
provide a single host as part of a command-line inventory to *Ansible*, a
trailing comma is required to ensure the inventory is interpreted as a
hosts list and not an inventory file.
```sh
ansible-playbook -i "hostA," -e "alacritty_update_bashrc=true" alacritty-install.yml
```

Since *Alacritty* has its own *Terminfo*, a playbook is provided to install
just the *terminfo* into remote hosts to avoid unknown TERM issues.
Alternatively, the *xterm* or *xterm-256color* terminfo's have proven
reasonably compatible.
```sh
ansible-playbook -i "remotehost1,remotehost2" alacritty-terminfo.yml"
```

If a host inventory files is preferred instead, create a *hosts.yml*
such as the following example.
```yaml
---
all:
  hosts:
    hostexample01:
      ansible_host: 192.168.10.65
  vars:
    ansible_install_dir: "/opt/alacritty"
    ansible_themes_dir: "/opt/alacritty_themes"
    alacritty_update_bashrc: false
    alacritty_update_aliases: false
```

### Ansible Tags

A typical installation uses all tags centered around *term*, which is the
primary installation. Additional tags can be specified to target parts of
the playbook separately.

|  Tag Name      |  Description                  |
|----------------|-------------------------------|
| *term*         | Builds and installs Alacritty |
| *terminfo*     | Installs system TermInfo      |
| *term-config*  | Installs bash configuration and functions |
| *term-themes*  | Installs Alacritty themes      |


## Alacritty Configuration

Alacritty uses a *toml* configuration file that it will look for in a few
standard locations. The provided Ansible and the Bash Functions will use the
standard location of *${HOME}/.config/alacritty/alacritty.toml* for the default
configuration. This configuration is used as the predefined *default* profile
which is considered special by the profile handling.


### Enabling Alacritty Profiles

The profile handling abilites come from the provided Bash script installed
as *.config/alacritty/alacritty_functions.sh* and should be added to *.bashrc*
along with the provided bash_completion script. The Ansible variables
*alacritty_update_bashrc* and *alacritty_update_aliases* respectively can
be used to update the *.bashrc* file and *.bash_aliaes* file. The block added
to the *.bashrc* file is as follows. Note both of these variables are defaulted
to *false*.
```bash
if [ -r  ~/.bash_completion/alacritty ]; then
    source ~/.bash_completion/alacritty
fi
if [ -r ~/.config/alacritty/alacritty_functions.sh ]; then
    source ~/.config/alacritty/alacritty_functions.sh
    critty_config >/dev/null  # ensures a 'default' config is created
fi
```

Additionally, Debian-based hosts often set color options for terminals via
*.bashrc*. Simply add the *alacritty* terminal name to the existing case
statement.
```bash
case "$TERM" in
    xterm-color|*-256color|alacritty) color_prompt=yes ;;
esac
```

### New and Existing Profiles

The function *critty_functions_list* provides a list of available functions
for managing terminal profiles. To create a new profile use the *critty_new*
function. This will create a new terminal window with a profile specific
configuration. This is the primary function for opening existing profiles or
creating a new profile.
```bash
critty_new profile2
critty_profiles

Alacritty_Profiles:
 - default
 - profile2
Current Profile:
 - default
 ```

Note the current profile above is still listed as *default* as the
*critty_profiles* function was executed in the original shell window
while *critty_new* creates a *new* terminal instance under the new profile.


### Alacritty Functions

The profile functions support adjusting the default window size (when
creating a new window), the window opacity, the font size, and the window
theme. Use *critty_themes* to get a list of available themes. These settings
are defined and saved in the profile specific configuration
*.config/alacrity/alacritty-${ALACRITTY_PROFILE_NAME}.toml*.


|  Function        |  Description                       |   Default Value    |
|------------------|------------------------------------|--------------------|
| critty_new       | Creates a new profile and window   |    'default'       |
| critty_font      | Sets the current profile font size |        9           |
| critty_win       | Sets the window dimensions         | '75x32' (rowsXcol) |
| critty_opac      | Sets the window opacity            |      .99           |
| critty_theme     | Sets the current window theme      |     Ubuntu         |
| critty_themes    | The list of available themes       |       n/a          |
| critty_style     | Switch to a preset style/theme     |     'dark'         |
| critty_set_style | Set or create a style setting      |       n/a          |
| critty_styles    | List of available styles           |       n/a          |

Most` functions will show the current value when no parameters are provided.
A few pre-configured set of theme *styles* are provided via additional
functions.

- *crittypro*  - Sets the *monokai_pro* theme with less transparency.
- *crittylite* - Sets the theme as *solarized_light* with no transparency.
- *crittydark* - Sets the default theme of *Ubuntu* with some transparency.

### Alacritty Styles

These are simply wrappers to the *critty_style()* function, thus the
function *crittypro* is the same as running `critty_style pro`. New styles
can be created or existing styles updated via *critty_set_style*.
```sh
critty_set_style pro catppuccin_mocha 9 0.98
```
