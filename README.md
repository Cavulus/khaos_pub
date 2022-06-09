# Khaos

Khaos is a companion to the [Khaos](https://github.com/Cavulus/khaos_commands) project that will provide a centralized configuration for your various environments.  With a simple khaos command, any developer on your team can spin up the exact same containerized environment and load the exact same code branches into these environments.  It's as easy as running: `box khaos up my-app` 

# Installation

## Prerequisites 
 * [CommandBox](https://www.ortussolutions.com/products/commandbox) 5.4.2 or later installed.
 * [Docker Desktop](https://docs.docker.com/desktop/) 4.1.1 or later
 * If on Mac, [Homebrew](https://brew.sh/) is recommended

## Install 
1. Clone [Khaos](https://github.com/Cavulus/khaos) repo:

    `git clone https://github.com/Cavulus/khaos.git`

2. Then, open a terminal to the root of this repo and issue the following command:

    `box install`
## Setup
Now you'll be presented with a setup wizard that will guide you through the setup process with the following prompts:

* Where would you like to install/manage KHAOS definitions?: `Defaults to current directory.  Type in actual directory path if different.`
* Enter Khaos Settings repository name: `Name of your private GitHub repo that will house the Khaos configurations.  This must already exist and should be a private repo as it will contain specifics about your infrastructure.  AS WITH ANY REPO, DO NOT STORE KEYS/SECRETS/PASSWORDS IN THIS REPO`
* Enter Khaos Settings branch: `The git branch name to use within the above github repo; i.e. master or main`
* Enter Khaos Release/Build repository name: `Name of your private GitHub repo that will house the Khaos builds.  This must also exist (if you intend to use this functionality) and should also be private.  This repo will enable users to share their current config with others in the organization.`
* Enter Khaos Release/Build branch: `The git branch name to use within the above github repo; i.e. master or main`
    ___
    ## Experimental (can leave blank)
* Enter Docker Repository Type: `Currently only "AWS" is supported. Will push docker images to ECR`
* Enter Docker Repository Account ID: `AWS Account ID of account where you will push images to ECR`
* Enter Docker Repository Repository Name: `ECR repository name to push images into`
* Enter Docker Repository Region: `AWS region in which you want to push images`
    ___
That's it!  Khaos is now installed and configured.  The next step is to define the environments/applications you wish to manage via Khaos.  If this has already been setup, you're ready install and run locally.
# Khaos Commands
With Khaos installed, you now have all the Khaos commands at your ready.  If your private Khaos config repo has already been configured with your environments, you can proceed with initializing and running the apps right away:
* [Initializing Projects/Environments](projects.md)
* [Project Settings](settings.md)
* [Interacting with Docker (i.e. start/stop containers)](https://github.com/Cavulus/khaos/commands/khaos/docker.md)

If Khaos configuration has not been completed yet for your applications, check out [this guide](https://github.com/Cavulus/khaos/README.md) to get started.
