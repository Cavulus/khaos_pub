component{
	
    public function run(string runners = '4', string key = 'whatever', string buildID = 'completeTestRun00'){
        
        if( !command( '!npm list -g | grep cypress').run( returnOutput=true ).len() )
            command('!npm install --save-dev cypress').run( );
        var cypressPath = command('!DEBUG=cypress:* cypress version').run( returnOutput=true );
        print.boldRedLine( cypressPath ).toConsole();
		if( !directoryExists ('/Volumes/Dev/sorry-cypress')){
            command( 'initialize --force env=sorry-cypress settingsbranch=local');
        }
        var jPattern = createObject("java", "java.util.regex.Pattern").compile('(?<=: )/.+Cypress.app/');
        var results = jPattern.matcher(cypressPath);
        results.find();
        cypressPath = '#results.group()#Contents/Resources/app/packages/server/config/app.yml';
        var appYML = fileRead( cypressPath );
        print.boldBlueLine(appYML).toConsole();
        fileWrite( cypressPath, reReplace( appYML, 'api_url: ".[^"]*"', 'api_url: "https://cypress.test.cavulus.com"', 'all' ));
        for( var iRunner = 1; iRunner <= arguments.runners; i++){
            print.boldRedLine( command('!cd /Volumes/Dev/genesis/app/server/tests && cypress run --record --key #key# --parallel --ci-build-id #buildID#').run( returnOutput=true ));
        }
        
        print.boldYellowLine('should have 3 running instances');

	}
}
