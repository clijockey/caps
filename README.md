# Cloud Automation Pipelines (CAPs)

## Overview

This repository contains deployment automation pipelines that can help launch scaled out production ready environments in the cloud. The automation tooling consist of [Terraform](https://www.terraform.io/) as the orchestrator and control plane for infrastructure services and [Concourse](http://concourse-ci.org/) for implementing operational workflows. Pipeline jobs may use a combination of configuration management tools to achieve their objective, but the primary configuration management tool used by the automation pipelines is [Bosh](http://bosh.io/).

A collection of utility scripts is provided in the `bin` folder to help manage multiple environments. Along with these scripts this repository is organized as follows.

```
.
├── bin           # Utility scripts for managing environments
├── deployments   # Deployments used to bootstrap environments
├── docs          # Additional documentation
├── lib           # Operations pipelines, scripts and templates
├── LICENSE      
└── README.md
```

Each environment is bootstrapped by an inception Virtual Private Cloud (VPC), which sets up optional infrastructure that will secure access to internal resources built via automation pipelines. 

## Usage

### Quick Start

To use this framework effectively a collection of shell scripts are provided. It is recommended to use a tool like [direnv](https://direnv.net/) to manage your local settings. 

The IaaS credentials for the IaaS on which an environment should be launched should be provided as environment variables. This can be achieved by exporting the variables from within an `.envrc` file if you are using [direnv](https://direnv.net/) to manage you localized environments. Otherwise simply save them to a shell script and source it before executing the CAPs utilities. 

> You should also add the `<repository home>/bin` folder your your path so you can run `caps-*` scripts without providing an explicit absolute or relative path.

The following IaaS specific environment variables are required by the bootstrap Terraform template.

* GCP

  ```
  export GOOGLE_PROJECT=****
  export GOOGLE_CREDENTIALS=<path to your service account key file>
  export GOOGLE_REGION=europe-west1
  export GOOGLE_ZONE=$GOOGLE_REGION-b

  export GCS_STORAGE_ACCESS_KEY=****
  export GCS_STORAGE_SECRET_KEY=****

  ```

  > For GCP download you service account key file and save to some path within your user file-system and reference it via the `GOOGLE_CREDENTIALS` variable.

* AWS

  TBD

* Azure

  TBD

A sample `.envrc` file is below.

```
PATH_add $(pwd)/bin

#
# Terraform AWS Cloud provider environment
#

export AWS_ACCESS_KEY=****
export AWS_SECRET_KEY=****
export AWS_DEFAULT_REGION=us-east-1

#
# Terraform Google Cloud provider environment
#

export GOOGLE_PROJECT=****
export GOOGLE_CREDENTIALS=<path to your service account key file>
export GOOGLE_REGION=europe-west1
export GOOGLE_ZONE=$GOOGLE_REGION-b

export GCS_STORAGE_ACCESS_KEY=****
export GCS_STORAGE_SECRET_KEY=****
```

#### `build-image`

Before you can bootstrap an environment for a particular IaaS you need to first build the bootstrap image. This is a multi-role image that is used to automate and secure access to the environment. To build the image run the following command.

```
USAGE: build-image -i|--iaas <IAAS_PROVIDER> [ -r|--regions <REGIONS> ]

    <IAAS_PROVIDER>  The iaas provider for which images will be built.

    <REGIONS>        Command separated list of the iaas provider's regions for which
                     images will be built. This does not apply to all providers.
```

All build logs will be written to the `<repository home>/log` folder.

* GCP

  GCP images are global and not region specific so the `-r|--regions` argument will be ignored.

  ```
  build-image -i gcp
  ```

* AWS

  For AWS if the `-r|--regions` argument is not provided then images will be built for all the available regions.

  ```
  build-image -i aws -r us-east-1
  ```

* Azure

  TBD

#### `caps-init`

#### `caps-tf`

#### `caps-ci`

#### `caps-vpn`

#### `caps-ssh`

#### `caps-info`


### Advance Users

Advance users can extend the framework to override the default reference network as well as service configurations to create production ready environments.

## Bootstrapping Approach

Every environment needs to be bootstraped. The bootstrap step paves the IaaS with the necessary services required for secured access to a logical Virtual Data Center (VDC) created for the environment. Bootstrapping is achieved via Terraform templates. This initial template contains all the required parameters that setup the rest of the automation workflows. Bootstrapping is done by applying a Terraform template that launches an inception Virtual Private Cloud which also acts as the DMZ layer for the rest of the deployed infrastructure.

### Bootstrap Image

The framework depends on a pre-configured cloud image that bootstraps the environment. The instance launched using this image can have multiple roles and these roles can be combined into a single instance or scaled out based on the environment needs. The image can be configured to have one or more of the following service roles.

* Concourse Automation Service

  Once the initial IaaS infrastructure has been bootrstapped this service will be configured with a bootstrap pipeline that is responsible for setting up the required automation to complete the build of the environment. To ensure that the configurations which these pipelines orchestrate are idempotant this pipelines use Terraform as the control plane and Bosh as the runtime state. The state for both Terraform and Bosh is saved to an IaaS provided object store. This ensures that if the instance hosting this service is rebuilt it will rediscover the current state.

  >> An S3 store which is backed by a persistent volume is provided as a backup mechanism natively. This can be used for environments that do not have access to an IaaS provided object store.

* VPN Service
* HTTP Proxy Service
* *SMTP Service (TBD)*
