#!/bin/bash
# PyInit
# Python2/Python3 environment initializer
# Designed for penetration testing tools and exploit development
#
# Author: DesertSecLab

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

SOURCE_LINE="source $SCRIPT_DIR/py-init.sh"


if grep -Fxq "$SOURCE_LINE" ~/.bashrc; then

    echo "PyInit is already installed."

else

    echo "$SOURCE_LINE" >> ~/.bashrc

    echo "PyInit installed successfully."

fi


echo "Run:"
echo "source ~/.bashrc"
