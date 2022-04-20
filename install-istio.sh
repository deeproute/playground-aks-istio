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

function git_clone()
{
    local -r git_url="${1}"; shift;
    local -r folder_path="${1}"; shift;

    mkdir -p "${folder_path}"

    git clone "${git_url}" "${folder_path}"
}

function install_istio_operator()
{
    local -r istio_clone_path="${1}"; shift;
    local -r istio_git_url="git@github.com:istio/istio.git"

    # If folder_for_istio directory doesn't exist then create a new istio clone
    [ ! -d "${istio_clone_path}" ] && git_clone "${istio_git_url}" "${istio_clone_path}"
    
    kubectl create ns istio-operator
    helm install istio-operator "${istio_clone_path}"/manifests/charts/istio-operator -n istio-operator
}

function main()
{
    local -r folder_for_istio_git="${1}"; shift;
    local -r istio_config="${1}"; shift;

    local -r prerequisites=("git" "helm" "kubectl")
    check_prerequisites "${prerequisites}"
    
    install_istio_operator "${folder_for_istio_git}"

     # Configure istio-operator to create the istio-system control plane components
    kubectl create ns istio-system
    kubectl apply -f "${istio_config}/istio-base-install.yaml"
    
    # Create the Ingresses
    # Its a best security practice to create the ingress gateways outside the istio-system namespace
    # https://istio.io/latest/docs/setup/additional-setup/gateway/#deploying-a-gateway
    # Create public ingress with Azure Public LB
    kubectl create ns istio-ingress-public
    kubectl apply -f "${istio_config}/ingress-plb.yaml"
    
    # Create internal ingress with Azure internal LB
    kubectl create ns istio-ingress-internal
    kubectl apply -f "${istio_config}/ingress-ilb.yaml"
}

main "${@}"
