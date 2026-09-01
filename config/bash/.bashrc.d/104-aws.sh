if [ -z $BASH_INIT_AWS ]; then
    function awsb01() { aws --profile openshift-ci-build-farm-infra-01 $@; }
    function awsb11() { aws --profile openshift-ci-build-farm-infra-11 $@; }
    function awsci() { aws --profile openshift-ci-infra $@; }
    export -f awsb01
    export -f awsb11
    export -f awsci
    # Shell commands completion: https://docs.aws.amazon.com/cli/v1/userguide/cli-configure-completion.html#cli-command-completion-linux
    complete -C aws_completer aws
    export BASH_INIT_AWS=1
fi
