function py-init() {

    # 1. Force mode handling: -3 force Python3, -2 force Python2
    if [ "$1" = "-3" ]; then
        echo -e "\n\033[1;36m[🔄 MODE]\033[0m Force enable Python 3 clean mode..."
        [ -d "venv/bin" ] && [ -f "venv/bin/activate" ] && source venv/bin/activate && echo -e "\033[1;32m🚀 Python 3 venv restored successfully!\033[0m\n" && return 0
        local force_py3=1

    elif [ "$1" = "-2" ]; then
        echo -e "\n\033[1;36m[🔄 MODE]\033[0m Force switch to pyenv Python 2.7.18..."
        pyenv local 2.7.18 2>/dev/null && echo -e "\033[1;32m🚀 Python 2.7.18 is ready!\033[0m\n" && return 0
    fi


    # 2. Fast restore logic (reuse existing environment)
    [ -z "$force_py3" ] && [ -d "venv/bin" ] && [ -f "venv/bin/python" ] && [ -f "venv/bin/activate" ] && source venv/bin/activate && echo -e "\n\033[1;32m🚀 Python 3 venv restored successfully!\033[0m\n" && return 0

    [ -z "$force_py3" ] && [ -f ".python-version" ] && grep -q "2.7.18" .python-version 2>/dev/null && echo -e "\n\033[1;32m🚀 Python 2.7.18 automatically configured!\033[0m\n" && return 0


    # 3. Check if current directory contains Python files
    if [ -z "$force_py3" ] && [ -z "$(find . -maxdepth 3 -name "*.py" -print -quit 2>/dev/null)" ]; then
        echo -e "\n\033[1;33mℹ️ No Python scripts detected in current directory (max depth: 3).\033[0m\n"
        return 0
    fi


    # 4. Detect Python version based on script characteristics
    local py_cmd="python3"

    if [ -z "$force_py3" ]; then

        local py2_regex="^\s*(print\s+['\"]|xrange\s*\(|raw_input\s*\(|except\s+\w+,\s*\w+:|import\s+(urllib2|ConfigParser|StringIO|commands))"

        local has_py2=$(find . -maxdepth 3 -name "*.py" -exec grep -lE "$py2_regex" {} + 2>/dev/null | head -n 1)

        if [ -n "$has_py2" ]; then

            echo -e "\n\033[1;31m⚠️ Python 2 syntax detected (source: $has_py2)\033[0m"

            command -v pyenv &>/dev/null && pyenv local 2.7.18 &>/dev/null && echo "🔄 pyenv Python 2.7.18 activated"

            py_cmd="python"

        fi
    fi


    # 5. Dependency checking function
    _py_check_deps() {

        local current_py=$1
        local mode=$2


        if [ "$mode" = "-3" ]; then

            echo "ℹ️ Clean mode: dependency scan skipped."

            return 0

        fi


        if [ -f "requirements.txt" ]; then

            echo "📋 requirements.txt found, installing dependencies..."

            python -m pip install -r requirements.txt

        else

            echo "ℹ️ No requirements.txt found. 🔍 Scanning missing modules..."


            local libs=$(grep -rhE "^\s*(import|from)\s+\w+" --include="*.py" . 2>/dev/null | awk '{print $2}' | tr -d ',;' | sed 's/\..*//' | sort -u | tr '\n' ' ')


            local missing=$($current_py -c "
import sys
missing = []
for lib in '$libs'.split():
    try:
        __import__(lib)
    except ImportError:
        missing.append(lib)
print(' '.join(missing))
" 2>/dev/null)


            local final_missing=""

            for m in $missing; do

                [ ! -f "${m}.py" ] && [ ! -d "$m" ] && final_missing="$final_missing $m"

            done


            final_missing=$(echo "$final_missing" | xargs)


            [ -n "$final_missing" ] \
            && echo -e "⚠️ Missing modules. Install with: \033[1;33mpip install $final_missing\033[0m" \
            || echo "✅ No obvious missing dependencies detected."

        fi
    }


    # 6. Execute according to Python version

    if [ "$py_cmd" = "python" ]; then

        _py_check_deps "python" "$1"

        echo -e "\033[1;32m🚀 Python 2 environment configured!\033[0m\n"


    else

        python3 -c "import venv" &>/dev/null || {
            echo -e "\033[1;31m❌ python3-venv is missing. Install with: sudo apt install python3-venv\033[0m\n"
            return 1
        }


        echo "📦 Creating and activating new virtual environment..."


        python3 -m venv venv && source venv/bin/activate || return 1


        python -m pip install --upgrade pip &>/dev/null



        if [ "$1" = "-3" ]; then

            _py_check_deps "python3" "$1"

            echo -e "\033[1;32m🚀 [Clean Mode] Python 3 venv enabled!\033[0m\n"

            return 0

        fi



        local dep_file=$(find . -maxdepth 3 \( -name "setup.py" -o -name "pyproject.toml" \) 2>/dev/null | head -n 1)


        if [ -n "$dep_file" ]; then

            echo "📋 Project configuration found: $dep_file, installing..."

            (cd "$(dirname "$dep_file")" && pip install .)

        else

            _py_check_deps "python3" "$1"

        fi


        echo -e "\033[1;32m🚀 Python 3 venv environment configured!\033[0m\n"

    fi


    echo -e "💡 \033[1;35m[HELP]\033[0m Force Python2: \033[1;36mpy-init -2\033[0m | Force Python3: \033[1;36mpy-init -3\033[0m | Auto detect: \033[1;36mpy-init\033[0m"

}
