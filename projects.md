# Managing Development Environments with Khaos

## Prerequisites
In order to use Khaos you must have the following installed:

## Prerequisites 
 * [CommandBox](https://www.ortussolutions.com/products/commandbox) 5.4.2 or later installed.
 * [Docker Desktop](https://docs.docker.com/desktop/) 4.1.1 or later
 * If on Mac, [Homebrew](https://brew.sh/) is recommended
 * [Khaos](https://github.com/Cavulus/khaos)

# Introduction
Khaos is a command-line utility that provides a suite of functions that help to setup, run, tear down and build containerized environments for your various applications.  It was developed as a CommandBox module and so must be executed using the box executable or within the box cli.  With CommandBox installed, you can type `box` from a terminal to enter the CommandBox CLI (Command Line Interface).  You can also prefix commands with `box` instead of entering into the CLI.  For example `box initialize my-app` will run the initialize command through the CommandBox interpreter and return back to the regular terminal.

# Concepts/Terminology
Khaos is designed as a lightweight layer on top of docker compose that easily allows you to organize your systems into `apps` and `environments`.  

## Apps
In Khaos terms, an `app` is a directory inside the Khaos root that contains at minimum a `settings.json` file and a docker-compose yml file (i.e. `my-app.yml`).  Any other supporting configuraiton files (i.e. `cfconfig.json, Dockerfile, seed-data.sql` type files).  

The name of the app should match the directory name as well as the docker-compose file name.  Here's an example file structure for a Khaos configuration with two separate apps:
```
khaos
  |-myApp
    |-myApp.yml (docker copmose)
    |-settings.json (khaos app configurations)
  |-myOtherApp
    |-myOtherApp.yml
    |-settings.json
  ...
  projects.json (Khaos project registry - describes apps and environments)
  secrets.json (Khaos global secret prompts - uses this to prompt users for global secrets)
  settings.json (Khaos global settings - applies to all apps/environments)
```
The docker-compose file could define multiple services, i.e. cfml server, db server, etc...but should only include a single `app`.  If you have multiple apps that interact with each other, consider creating an `environment`.

## Environments
Environments in Khaos are simply a collection of `apps`.  These are defined in the root of the Khaos directory as a docker-compose file with the naming convention: `<environment name>-environment.yml`.  These docker-compose files should describe any service and/or app that you wish to spin up as a single network of services.  Here's an example:
```
services:
  # NGINX Container
  nginx-proxy:
    extends:
      file: reverse-proxy/nginx.yml
      service: nginx-proxy

  # My App Server
  myApp_server:
    extends:
      file: myApp/myApp.yml
      service: myApp_server
    depends_on:
      - "nginx-proxy"

  # My Other App Server
  myOtherApp_server:
    extends:
      file: myOtherApp/myOtherApp.yml
      service: myOtherApp_server
    depends_on:
      - "nginx-proxy"
      
  # Testing/Development Email Server
  mailhog:
    extends:
      file: mailhog/mailhog.yml
      service: mailhog
    depends_on:
      - "nginx-proxy"
networks:
  khaos_network:
    driver: bridge
    ipam:
      driver: default
      config:
        - subnet: ${NETWORK_SUBNET:-10.5.0.0/16}          
```
This `environment` would bring up an nginx server, a testing smtp server and two apps: __myApp__ and __myOtherApp__.  Notice the use of file references in the docker-compose yaml file to include the apps rather than full definitions.  This allows you to potentially create several environments that have different combination of `apps` and/or other services.

In additon to this docker-compose file, the environment needs to be defined in the `/khaos/projects.json` file:
```
{
"myApp":["myApp"],
"myOtherApp":["myOtherApp"],
"full":["myApp","myOtherApp"],
}
```
Khaos uses this file to load the appropriate configurations (outside of docker-compose).  It's used to generate and install ssl certificates, generate host names, etc...

# Commands
Now that you have `app(s)` and optionally `environment(s)` defined, you can interact with them using Khaos commands.  The core functions around managing your local development environments are:

`> box khaos initialize <app or environment>`

(or shorthand `box kinit <app or environment>`)

`> box khaos <up,down,reset>`

## Initialize App/Environment:
To initialize an app that has been configured in Khaos (i.e. you're setting up a devloper's machine), you'll simply:
```
> cd ~/my/project/path
> box khaos initialize myApp
```
This will read the `settings.json` and using any other assets described in the project's folder and will pull git repos, run scripts, etc... to initalize your application.  This initialized app is then registered into Khaos so that from your terminal you can run the app, regardless of which directory you are in.

> Note: In the above example, _myApp_ could be an entire suite of apps (aka `environment`), in which case it will install, initialize each `app` defined in the environment (per `projects.json`).

# `initialize` (`kinit`) Arguments
The initialize command also accepts the following optional arguments:

* __string env__:  `The name of the app or environment (pre-defined collection of apps) that you wish to initialize.  If omitted, choices will be presented.`
* __string branch__: `The branch to clone.  This can (should) be omitted as Khaos will clone the repositories at the branch specified in the Khaos settings for each application.  If you need to change the branch(s), do so after initializing. `
* __string path__: `The directory into which Khaos will install the application files.  The default if omitted will be the current terminal directory.`
* __string settingsBranch__: `Khaos reads application settings directly from the Khaos repository on GitHub (whenever possible) so that the latest changes are always reflected.  If you need to read Khaos settings from another branch, specify the branch name here.  You may also supply the keyword: local and it will read from the settings files in your local Khaos directory.  Lastly, you can supply the keyword build: along with a tag/release name (i.e. build:rc1.2.3) and Khaos will pull the settings down from the khaos_builds repository.`
* __boolean force__: `If true, Khaos will delete the directory (or directories) for each application it is initializing.  This will destroy your local .git file and so you will lose any branches/changes not pushed to GitHub.  You will also lose any stashes you may have locally.  Generally you do not want this.  Default if omitted is false.`
* __boolean switch__: `If true, Khaos will check the branch and state of each module/dependency. If the branch is different than what is described in the "settings.json" file it will check out the described branch and pull.  If the branch is already the same, it will check for updates and pull if necessary. `
* __boolean run__: `If true, once the application or environment is finished initializing it will spin up the docker environment in detached mode.  This will take a few minutes, but when completed you will be able to navigate to the site in your browser without any further interaction on your part. Default if omitted is false.`
* __boolean reloadSettings__: `If true, the internal Khaos settings will be reloaded prior to initializing.  You would pass false in cases where you've manually added settings to your ~/.CommandBox/.khaos-settings.json file for debugging purposes. Default if omitted is true.`
* __boolean build__: `If true, will run any post-initialize scripts defined in the settings.json file of each application that was initialized.  This is typically for installing and building front-end JS libraries via NPM scripts.  Default if omitted is false.`
* __boolean threadedBuild__: `If true, and build is true, will cause the defined scripts to run in a threaded fashion.  This dramatically reduces the time it takes to run the scripts, but will run them all at once at the end of the initialization (instead of inline during each module/dependency initialization).  Default if omitted is false.`
* __boolean resetSecrets__: `If true, Khaos will delete any secrets that were previously provided and prompt the user for new values before it can initialize. Default if omitted is false.`
* __boolean selfSignedSSL__: `Default true. If true, will create and install self signed SSL certificates.`
* __boolean buildOnly__: `Default false. If true, will create the docker image, but not start it.`

### To update an already initialized application/environment
If you're working on an application that has new modules/dependent repositories, then you need to re-initialize the application.  This is common on projects where every module resides in its own repository.

To get the new modules or other repository dependencies setup in your environment:
Open your terminal and cd to the parent directory of the application you want to re-initialize.  For instance, if your myApp application is installed at ~/webs/myApp you'll
```
cd ~/webs/myApp
```
Then execute the following command:
```
box kinit myApp
```

Note that the above command example will only act on the myApp application. You can also pass it an environment instead and it will update all apps in the environment accordingly.

> This will only clone new dependencies and will not override any existing ones.  It will also update your Khaos settings and .env file appropriately.  If you wish to re-clone everything, pass the `--force` command and it will delete and re-clone all dependencies for the given application or environment. __ANY LOCAL GIT HISTORY WILL BE LOST, SO MAKE SURE TO COMMIT/PUSH BEFORE FORCING AN INIT__

If the new modules or other repository dependencies are on your local machine and not yet pushed to github, you can supply the branch from which to pull the `settings.json` files from as local, for instance:
```
box kinit env=myApp settingsBranch=local
```
This will read the settings from your local Khaos directory and apply them accordingly.  You can also supply a specific branch name to this argument and it will fetch the settings from that branch on GitHub.  
> You may also pull these settings from the Khaos_Builds repo by supplying the keyword build: along with the release/tag name (i.e. settingsBranch=build:rc1.0.0)

Often when pulling in new modules/dependencies its prudent to re-build any JS assets that may have changed since the last time you initialized.  For this reason, it is recommended that when you re-initialize that you pass the --build argument to trigger any post-initialize build scripts to run.  For example:
```
box kinit myApp --build
```

## Runing an App/Environment:
Once your app or environment is initialized, you'll probably want to run it.  I mean, that's why we're here, right?

Khaos has commands that allow you to up, down, reset your docker containers.  

To run your app/environment; open a terminal (doesn't matter where), execute the following command:
```
> box up myApp
```
This will build the docker container (if not already built) and will run it in docker desktop.  It will also generate SSL certificates, ask for any required secrets (first time only or if new secrets have been added), etc...

That's it.  The terminal session will now be tied to that docker environment and will "tail" the logs from each server.  If you `CTRL+C` in the terminal, or close the terminal session the docker instances will stop.  To run the docker containers in detached mode (meaning it'll run in the background, and not be tied to the terminal session), simply pass the `--d` argument:
```
box up myApp --d
```
When the up command is run, Khaos will inspect its settings to see which containers need to be brought up.  If they don't exist it will build them, then run them.  These settings are pulled directly from GitHub, however if you've manually changed any Khaos settings (i.e. modified the various .yml files inside the Khaos project) it will warn you that it could not fetch the latest settings and will use the local settings instead.  You typically won't need to modify the settings locally, so should only see that message if you expect it.

# `up` Arguments
* __env__: `The environment or container name (or comma separated list of environments/containers) to build/start - The name of the yml file without extention (can also omit '-environment')`
* __detached__: `If true will run the docker containers in detached mode, in which they will run in the background and not tied to the terminal session. Alias `--d` can be used instead.`
* __fetchLatest__: `Default, true.  If false the current local Khaos yml files will be used.  If true Khaos will pull the latest from the remote (current branch) before running "docker-compose up".`
* __scale__: `Pass the service name and number of instances (i.e. webserver=3) or a list of name=number to run multiple instances (docker handles round robin load balancing)`
* __scale__: `Arbitrary comma separated list of docker params to pass to the up command`

## Other Khaos Commands
Khaos also has the `down` command which will shut down the docker container(s).  Inline with the Docker world, the down action will stop the container and delete it.  This means the next time you `box up` you'll get a completely fresh container, with any server settings or container files reverted back to the original state. 

To shut down your container(s) simply:
From a terminal (doesn't matter where), execute the following command:
```
box down myApp
```
That's it.

>Tip: You can omit the `app` or `environment` from the `up` and `down` commands.  If omitted, Khaos will present you with a selection to choose from.  This is handy if you don't know which apps/environments are available.

## Resetting Docker Images, Containers and/or Networks
In some cases, especially if you frequently use docker containers outside of the Khaos ecosystem, you can run into Docker conflicts where a container or network fails to load, or a stale Docker image fails to update.  For those edge cases, Khaos provides a reset command.  This command will guide you through a series of prompts to determine what to reset. 

To reset your docker assets:
From a terminal (doesn't matter where), execute the following command:
```
box reset
```
The first prompt will ask you if you wish to delete __ALL Containers, Images and Networks__ or __hand-pick__ which to delete.  You use your arrow keys to navigate to your desired selection and press the spacebar to select.  Once selected, press enter to continue.  

If you select __"Hand-Pick"__ you'll be prompted with similar options for `Images`, `Containers` and `Networks`.  In those prompts, if you chose __"Hand-Pick"__ you will be presented with a list of items to delete.  You can likewise select which `Images`, `Containers` and `Networks` you wish to delete.  Before anything is actually deleted you will be presented with a summary of the changes to take place and given the opportunity to abort or continue.

> Note: If deleting images, be aware that these are large files and often shared with other docker containers.  If deleted, the next time either of those containers are `up`'d, they'll need to download the image, which on slow connections could take a long time.
