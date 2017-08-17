#!/bin/bash

source /var/onap_tests/_test_base
source /var/onap/portal

covered_functions=(
"clone_all_portal_repos"
"compile_all_portal_repos"
"install_mariadb"
"install_portal"
)

# test_clone_all_portal_repos() - Verify cloning of Portal source code
function test_clone_all_portal_repos {
    clone_all_portal_repos

    asserts_file_exist $src_folder
    asserts_file_exist $src_folder/sdk
}

# test_compile_all_portal_repos() - Verify compiling of Portal source code
function test_compile_all_portal_repos {
    clone_all_portal_repos
    compile_all_portal_repos

    asserts_file_exist $src_folder
}

# test_install_mariadb() - Verify cloning of MariaDB docker image
function test_install_mariadb {
    install_mariadb
    asserts_image data_vol_portal
}

# test_install_portal() - Verify installation of Portal services
function test_install_portal {
    clone_all_portal_repos
    install_mariadb
    install_portal

    asserts_image widget-ms
    asserts_image_running widget-ms
}

if [ "$1" != '*' ]; then
    unset covered_functions
    covered_functions=$1
fi
main "${covered_functions[@]}"