#!/bin/sh

uname="/bin/uname"

kernel=$($uname -s)
nodename=$($uname -n)
kernel_rel=$KERNEL_VERSION
kernel_ver=$($uname -v)
machine=$($uname -m)
processor=$($uname -p)
hw=$($uname -i)
os=$($uname -o)

uname_output() {
    $uname "$1";
    exit $?
}

for arg in "$@"; do
    if [ "${arg:0:1}" = "-" ]; then
        case "$arg" in
            --help) uname_output "$arg" ;;
            --version) uname_output "$arg" ;;
            -a|--all)
                echo "$kernel $nodename $kernel_rel $kernel_ver $machine $processor $hw $os"
                exit $? ;;
            -s|--kernel-name) ;;
            -n|--nodename) ;;
            -r|--kernel-release) ;;
            -v|--kernel-version) ;;
            -m|--machine) ;;
            -p|--processor) ;;
            -i|--hardware-platform) ;;
            -o|--operating-system) ;;
            *) uname_output "$arg" ;;
        esac
    else
        uname_output "$arg"
    fi
done

for arg in "$@"; do
    case "$arg" in
        -s|--kernel-name) echo -n "$kernel";;
        -n|--nodename) echo -n "$nodename";;
        -r|--kernel-release) echo -n "$kernel_rel";;
        -v|--kernel-version) echo -n "$kernel_ver";;
        -m|--machine) echo -n "$machine";;
        -p|--processor) echo -n "$processor";;
        -i|--hardware-platform) echo -n "$hw";;
        -o|--operating-system) echo -n "$os";;
    esac
done

# new line
echo 
