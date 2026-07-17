# PyInit

Every time I run tools with Python, it gives me a huge headache. Some tools are written in Python 2, while others are written in Python 3, and running them throws all kinds of errors. On top of that, installing various Python packages sometimes messes up the system's Python environment. So I created a Python initialization tool and placed it in the .bashrc file. Whenever I need to run a tool, I just type the py-init command, and it automatically detects whether the tool requires Python 2 or Python 3, then activates the corresponding Python environment. If the detection is wrong, I also have a force-switch option — I can type py-init -2 or py-init -3 to manually enter the desired Python environment.

Designed for:

- Penetration Testing
- CTF
- Exploit Development

## Requirements

- Linux environment
- bash
- pyenv (optional, required for Python2 tools)
- Python 2.7.18 installed via pyenv

## Install

git clone https://github.com/xxx/PyInit.git

cd PyInit

chmod +x install.sh

./install.sh


## Usage


Automatic detection:

py-init


Force Python2:

py-init -2


Force Python3:

py-init -3
