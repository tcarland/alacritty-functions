Alacritty Functions v25.03.10
=============================

Provides an Ansible role and additional *Bash* functions for 
installing and managing [Alacritty](https://github.com/alacritty/alacritty) 
terminals on Debian Linux-based hosts.

The *Bash* functions included offers additional functionality 
for creating and managing profiles by defining multiple Alacritty 
configurations. This allows for the dynmamic, real-time adjustment 
of various Alacritty features such as themes, window opacity, and 
font sizes.


## Requirements

Ansible 8.5.0+ is required to install the Alacritty playbook.
The Bash functions require Bash 4+, with Bash 5+ being fairly 
standard on modern linux distributions. 


## Installation

Installation involves creating an inventory file and running the 
playbook. The file *hosts-example.yml* serves as a template to an 
inventory configuration. 
```sh
cp hosts-example.yml hosts.yml
```

Once the inventory is created, simply run *ansible-playbook*
```sh
ansible-playbook -i hosts.yml alacritty-playbook.yml
```


## Alacritty Configuration

Alacritty uses a *toml* configuration file that it will look
for in a few standard locations. The provided Ansible and the 
added Bash functions will use the standard location of 
*${HOME}/.config/alacritty/alacritty.toml* for the default
configuration. 

This initial configuration defines our *default* profile and 
is used as the initial configuration. 


## Alacritty Profiles

The profile handling abilites come from the provided Bash script 
installed as *~/.config/alacritty/alacritty_functions.sh* and 
should be added to *.bashrc* along with the provided 
bash_completion script
```bash
if [ -r  ~/.bash_completion/alacritty ]; then
    source ~/.bash_completion/alacritty
fi
if [ -r ~/.config/alacritty/alacritty_functions.sh ]; then
    source ~/.config/alacritty/alacritty_functions.sh
    critty_config >/dev/null  # ensures initial config is created
fi
```

The function *critty_functions_list* provides the list of available 
functions for managing terminal profiles. To create a new profile 
simply use the *critty_new* function. This will create a new 
terminal window with a profile specific configuration. This is the 
primary function for opening existing profiles or creating a new 
profile.
```bash
critty_new profile2
critty_profiles

Alacritty_Profiles:
 - default
 - profile2
Current Profile:
 - default
 ```

Note the current profile here is still listed as *default* above as 
the *critty_profiles* function was still executed in the original 
shell session/window since *critty_new* creates a new terminal 
window.

### Alacritty Functions

The functions support adjusting the default window size (when 
creating a new window), the window opacity, the terminal font size, 
and the Alacritty theme. Use *critty_themes* to get a list of 
available themes.

|  Function    |  Description                       |  Default Value  |
|--------------|------------------------------------|-----------------|
| critty_new   | Creates a new profile and window   |   'default'       |
| critty_font  | Sets the current profile font size |     9      |
| critty_win   | Sets the window dimensions         | 75 col x 32 rows |
| critty_opac  | Sets the window opacity            |    .99     |
| critty_theme | Sets the current window theme      |  Ubuntu         |
| critty_themes | The list of available themes      |     n/a         |

Each function will show the current value when no parameters are 
provided. A few pre-configured themes are provided via additional 
fucntions.

- *crittypro*  - Sets the *monokai_pro* theme with less transparency.
- *crittylite* - Sets the theme as *solarized_light* with no transparency.
- *crittydark* - Sets the default theme of *Ubuntu* with some transparency.

