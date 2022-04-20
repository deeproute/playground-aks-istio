#! /usr/bin/env bash

# abort on nonzero exitstatus
set -o errexit

# abort on unbound variable
set -o nounset

# don't hide errors within pipes
set -o pipefail

function check_prerequisites()
{
    local -r prerequisites="${@}"

    for item in "${prerequisites[@]}"; do
        if [[ -z $(which "${item}") ]]; then
            echo "${item} cannot be found on your system, please install ${item}"
            exit 1
        fi
    done
}

function create_infra()
{
    cd terraform \
    && terraform init \
    && terraform apply -auto-approve \
    && cd .. \
    && az aks get-credentials --admin -g playground-aks-istio -n aks-istio --overwrite-existing
}

function git_clone()
{
    local -r git_url="${1}"; shift;
    local -r folder_path="${1}"; shift;

    mkdir -p "${folder_path}"

    git clone "${git_url}" "${folder_path}"
}

function main()
{
    local -r folder_for_istio_git="${1}"; shift;
    local -r istio_config="${1}"; shift;

    # Check first if any CLI tool is missing.
    local -r prerequisites=("git" "terraform" "az" "helm" "kubectl")
    check_prerequisites "${prerequisites}"

    # Create the AKS cluster
    create_infra
    
    # Install istio operator
    ./install-istio.sh "${folder_for_istio_git}" "${istio_config}"
}

main "${@}"
