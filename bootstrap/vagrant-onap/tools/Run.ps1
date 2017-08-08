switch ($args[0])
    {
        "all_in_one" { $env:DEPLOY_MODE="all-in-one" }
        { @("dns", "mr", "sdc", "aai", "mso", "robot", "vid", "sdnc", "portal", "dcae", "policy", "appc") -contains $_ } { $env:DEPLOY_MODE="individual" }
        "testing"
            {
                $env:DEPLOY_MODE="testing"
                $test_suite="*"
                if (!$args[1]) { $test_suite=$args[1] }
                $env:TEST_SUITE=$test_suite
                $test_case="*"
                if (!$args[2]) { $test_case=$args[2] }
                $env:TEST_CASE=$test_case

                rm ./opt/ -Recurse -Force
                rm $HOME/.m2/ -Recurse -Force
             }
    }

vagrant destroy -f $args[0]
vagrant up $args[0]
