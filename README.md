# AKS Istio Setup with public & internal ingress

## Overview

This guide showcases how istio can be configured to use a public and internal ingress.
This example uses the istio operator.

> ### Note
> Installing istio components through helm charts is being [deprecated](https://discuss.istio.io/t/timelines-for-helm-installation-deprecation/4709/13)
>
> If you want to install through gitops/helm then the [recommended way](https://discuss.istio.io/t/istios-helm-support-in-2020/5535/24) is to use the Istio Operator.

## Requirements

To run this repo `bootstrap.sh` script, the following CLI tools need to be installed:
- terraform
- az
- kubectl
- helm
- git

## Steps

### Setup Infra

The infra code is inside the `terraform` folder. 

First login with your az login account:
```sh
az login
```

Then run the `bootstrap.sh` script:
```sh
./bootstrap.sh ~/projects/istio istio-config
```

The `bootstrap.sh`:
- Creates an AKS cluster
- Installs the istio operator
- Configures istio operator to create the istio system control plane components
- Configures istio operator to create both the public and internal ingresses

`Arg 1`: Path where the istio helm chart is located. If the folder doesn't exist then a git clone is performed in the [istio github repo](https://github.com/istio/istio). As of this writting, [there isn't an official helm chart for the istio operator](https://istio.io/latest/docs/setup/install/operator/#deploy-the-istio-operator).

`Arg 2`: Path where all the configs for the istio operator are located.


### Test Sample App

```sh
kubectl create ns test-app
kubectl label namespace test-app istio-injection=enabled --overwrite 
kubectl apply -f app/.
```

## References

- [Deploying Multiple Ingress Gateways](https://www.youtube.com/watch?v=QIkryA8HnQ0&list=PLm51GPKRAmTnMzTf9N95w_yXo7izg80Jc&index=13&t=1530s&ab_channel=Tetrate)
- [Istio Operator Specification](https://istio.io/latest/docs/reference/config/istio.operator.v1alpha1)
- [Azure LB Annotations list](https://kubernetes-sigs.github.io/cloud-provider-azure/topics/loadbalancer/#loadbalancer-annotations)
- [How to configure Azure App Gateway in Istio](https://stackoverflow.com/questions/60113682/how-to-configure-azure-app-gateway-in-istio)
