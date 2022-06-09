/**
* 
* This is only meant to be called internally from Khaos.
* However, if you did want to run it you'd do something like this
*
* {code:bash}
* khaos-hooks onExpandHosts
* {code} 
* 
**/
component{
	/**
	 * Must return an array of subdomains to be used as replacements when expanding 
	 * wild cards in EXTRA_HOSTS property defined in settings.json.  This will expand
	 * a domain like *.domain.com into fully qualified domains.  For instance, if 
	 * the returned array was ["a","b","something"] and the EXTRA_HOSTS had a value  
	 * of *.domain.com then  the result would be
	 * a.domain.com
	 * b.domain.com
	 * something.domain.com
	 * 
	 * This is helpful for multi-tenant systems that use domain paths as tenant
	 * identifiers
	 */
    function run(){

        return serializeJSON(this.getSubdomains());
    }
	
	/**
	 * Private helper method to grab our tenants from the database
	 */
	private function getSubdomains(){
		return ["healthcheck","clienta","clientb"];
	/**
	 * Example db lookup for tenant/subdomains
	 */
	// 	try{
	// 		return queryExecute(
	// 			sql = "SELECT subdomain FROM clients",
	// 			options = {
	// 				datasource: {
	// 					"class": "org.postgresql.Driver",
	// 					"bundleName": "org.postgresql.jdbc42",
	// 					"bundleVersion": "9.4.1212",
	// 					"connectionString": "jdbc:postgresql://mydb.dev.internal.local:5432/my_user",
	// 					"username": "my_user",
	// 					"password": systemSettings.expandSystemSettings( "${SECRET_DSN_PASSWORD}" )
	// 				}
	// 			}
	// 		).valueList('clientId');

	// 	}catch(any e){
	// 		// Probably not connected to vpn... 
	// 		error("Error retrieving clients for onExpandHosts listener", "Unable to get list of clients.  Make sure you're on the VPN and try again.", e.errorCode);
	// 		abort;
	// 	}
	}
    
}
