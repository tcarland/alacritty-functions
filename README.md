Alacritty Functions v25.03.09
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
The Bash functions require Bash 4+

## Installation

Installation involves creating an inventory file and running the 
playbook. The file *hosts-example.yml* serves as a template to 
an inventory configuration. 
```sh
cp hosts-example.yml hosts.yml
```

Once the inventory is created, simply run *ansible-playbook*
```sh
ansible-playbook -i hosts.yml alacritty-playbook.yml
```

## Alacritty Configuration
