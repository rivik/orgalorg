# FIXME make it possible to specify non-system root dir
export _hastur_root_dir=${_hastur_root_dir:-/var/lib/hastur}

export _hastur_packages=${_hastur_packages:-bash,coreutils}

:hastur:keep-containers() {
    :hastur:destroy-containers() {
        echo -n "containers are kept in $_hastur_root_dir... "
    }

    :hastur:destroy-root() {
        :
    }
}

:hastur:keep-images() {
    :hastur:destroy-root() {
        echo -n "root is kept in $_hastur_root_dir... "
    }
}

:hastur:get-packages() {
    echo $_hastur_packages
}

:hastur() {
    mkdir -p $_hastur_root_dir

    :deps:hastur -q -r $_hastur_root_dir "${@}"
}

:hastur:init() {
    printf "Cheking and initializing hastur... "

    _hastur_packages+=",$1"

    hastur_out=$(
        :hastur -p $_hastur_packages -S /bin/true 2>&1 \
            | :progress:step \
    );
    if [ $? -eq 0 ]; then
        printf "ok.\n"
    else
        printf "fail.\n\n%s\n" "$hastur_out"
    fi

    trap :hastur:cleanup EXIT
}

:hastur:destroy-containers() {
    :hastur -Qc \
        | awk '{ print $1 }' \
        | while read container_name; do
            :hastur -D $container_name
        done
}

:hastur:destroy-root() {
    :hastur --free
}

:hastur:cleanup() {
    printf "Cleaning up hastur containers...\n"

    tests:debug() {
        echo "${@}" >&2
    }

    :hastur:destroy-containers

    :hastur:destroy-root

    printf "ok.\n"
}
