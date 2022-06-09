# App Settings (settings.json)
Each project/app folder will contain a settings file describing the repositories and directories required for the project. For example:
```json
{
    "directory": "${myapp.directory}",
    "repository": "https://github.com/MyOrg/myapp.git",
    "branch": "main",
    "projectFolder": "myApp/src",
	"workingDirectory": "${myapp.directory}/src",
	"hostAliases":[ "*.myapp.${MODE:dev}.myorg.com" ],
	"localConfigFile":{
        "name":"someConfig.cfc", 
        "path":"src/config/", 
        "template":"${khaos.path}myApp/someConfig.txt"
    },
    "modules": [{
        "name": "SomeModule",
        "path": "src/modules_app/",
        "repository": "https://github.com/MyOrg/myapp_somemodule.git",`
		"branch": "main",
		"scripts": ["npm run build", "some-bash-script.sh"]
    }],
   "dependencies": [{
        "repository": "git+ssh://git@github.com/someones/repo.git",
        "directory": "myApp",
        "branch": "main"
    }],
	"scripts": ["npm run build"],
	"initializeScripts":["cd src && box install"],
	"envVariables": {
		"MYAPP_APP_DIR": "${myapp.directory}src"
   },
   "secrets": [{
			"name": "dsn_password",
			"prompt": "Password for database connection",
			"scope": "global"
	}]
}
```
> NOTE: The `myapp.directory` value is set during the `initialize` command to match the location from which the command is executed.
> 
> Also, see [CommandBox documentation]([https://www.ortussolutions.com/products/commandbox](https://commandbox.ortusbooks.com/usage/system-settings)) for details on `${}` tokens and system variables.

# Settings Explained
* __directory__: `The parent directory into which the app is to be installed` 
* __repository__: `The git repository that contains the application code to pull`
* __branch__: `The branch in which to pull during "initialize" (branches can be switched at any time after initialization)`
* __projectFolder__: `The folder name of the app (usually the app name)`
* __workingDirectory__: `The folder from wich Khaos will execute scripts and other internal commands.`
* __hostAliases__: `Array of hostnames (wildcards ok) to add to the container's host file in addition to the host's hostfile.  SSL certificates will also be generated for these hostAliases`
* __localConfigFile__: `Optional.  This will define any config file that you'd like to place into the app folder during initialization.  This can be handy for instance to generate environment variables, or application specific variables that are to be injected into the application. This is value should be an object containing the following properties:`
    * __name__: `The name of the file you want Khaos to create (i.e. config.cfc)` 
    * __path__: `The path relative to "{myapp.directory}" that Khaos will write this file into.`
    * __template__: `Full path to the template that Khaos will use to generate the config file.  This can (should) contain ${} variables that will be replaced with static values during initialize`
 
* __modules__: `An array of module definitions that will be pulled/installed into the app.  These can be coldbox modules from ForgeBox.org, or git repositories. The module definitions options are as follows: `
    * __name__: `Name of the module`
    * __path__: `Path relative to {projectFolder} in which these modules will be installed`,
    * __repository__: `ForgeBox.io or git URI of the module`
    * __branch__: `Optional. Name of the git branch to pull from.`
    * __scripts__: `Array of scripts to run after pulling the module`

* __dependencies__: `Dependencies are just like modules, however they can be installed outside of the application directory. Generally usefull for non-ColdBox modules or external resources that you will mount into the container using Docker Compose volumes.  The dependency definitions are as follows:`
    * __name__: `Name of the dependency`
    * __path__: `Path relative to "${myapp.directory}" in which these modules will be installed`,
    * __repository__: `ForgeBox.io or git URI of the module`
    * __branch__: `Optional. Name of the git branch to pull from.`
    * __scripts__: `Array of scripts to run after pulling the module`
* __scripts__:`Array of scripts to run after pulling the application source code.  This only runs when the --build argument is passed to the initialize script` 
* __initializeScripts__: `Array of scripts to run each time the initialize command is executted.`
* __envVariables__: `Object containing Key/Value pairs of variables that will be injected into the container's environment variables (both os and Java)`
* __secrets__: `Array of secrets required by this app.  Khaos will prompt the user for these values during the first time the "up" command is executed.  It will then store those values until they are reset or changed in this file.  The secret definition looks like:`
    * __name__: `Name of the variable that the secret will be read into`
    * __prompt__: `Message presented to the user when prompting for the secret value`
    * __scope__: `The scope in which this secret is contained.  Either "global" or empty.  If empty it will be namespaced in the app's scope and not used in other apps when searching for secret values.  If "global" the secret value is stored in the global namespace and any app/environment controlled by Khaos can lookup that secret.`