# PyInit
Running Python-based security tools has always been frustrating. Some tools are written for Python 2, while others require Python 3. Switching between different Python versions and managing dependencies often leads to errors, conflicts, and broken environments.
To solve this problem, I created PyInit, a lightweight Python environment initialization tool integrated into my Bash environment.
Whenever I need to run a tool, I simply execute the `py-init` command. It automatically detects whether the tool requires Python 2 or Python 3, then activates the appropriate environment.
If the automatic detection is incorrect, I can manually switch environments using:
- `py-init -2` for Python 2
- `py-init -3` for Python 3

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
