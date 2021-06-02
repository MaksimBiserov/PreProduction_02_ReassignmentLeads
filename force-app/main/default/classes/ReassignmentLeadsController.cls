public with sharing class ReassignmentLeadsController {
    
    @AuraEnabled
    public static Map<String, List<String>> getDependentMap() {
        
        List<Region__c> regionItems = [SELECT Id, Name FROM Region__c];
        List<Country__c> countryItems = [SELECT Id, Name, Region__c FROM Country__c];
        List<String> stringRegions = new List<String>();
        
        Map<String,List<String>> results = new Map<String,List<String>>();

        for(Region__c regionItem : regionItems) {
            System.debug('regionItem: ' + regionItem.Name);
            List<String> stringCountries = new List<String>();

            for(Country__c countryItem : countryItems) {
                if(countryItem.Region__c == regionItem.Id) {
                    stringCountries.add(countryItem.Name);
                    System.debug('countryItem: ' + countryItem.Name);
                }
            }

            results.put(regionItem.Name, stringCountries);
        }

        System.debug('results: ' + results);

        return results;
    }

    @AuraEnabled
    public static void setLeads(String regionName, String stringCountryNames, String ownerName) {
        System.debug('regionName: ' + regionName);
        System.debug('stringCountryNames: ' + stringCountryNames);
        System.debug('ownerName: ' + ownerName);

        List<String> countryNames = stringCountryNames.split(';');
        System.debug('countryNames: ' + countryNames);

        Region__c region = [SELECT Id FROM Region__c WHERE Name =: regionName][0];
        List<Country__c> countries = [SELECT Id FROM Country__c WHERE Name IN: countryNames];
        String queryCountries = '';

        for(Country__c country : countries) {
            System.debug('country Id: ' + country.Id);
            queryCountries += '\'' + country.Id + '\' OR Country__c = ';
        }

        queryCountries = queryCountries.removeEnd(' OR Country__c = ');
        System.debug('queryCountries: ' + queryCountries);

        String query = 'SELECT Id, Name FROM Lead WHERE Region__c = ' +
                       '\'' + region.Id + '\' AND (Country__c = ' +
                       queryCountries + ')';

        System.debug('query: ' + query);

        User user = [SELECT Id, Name FROM User WHERE Name =: ownerName][0];

        BatchReassignment batch = new BatchReassignment(query, user.Id);
        Database.executeBatch(batch);
    }

    @AuraEnabled
    public static List<String> getOwnerNames() {

        Map<Id, Profile> profileIds = new Map<Id, Profile>(
            [SELECT Id, UserLicenseId
             FROM Profile
             WHERE UserLicenseId
             IN
                (SELECT Id
                 FROM UserLicense
                 WHERE Name ='Salesforce')]);

        List<User> users = [SELECT Id, Name
                                           FROM User
                                           WHERE ProfileId
                                           IN: profileIds.Keyset()];

        System.debug('users: ' + users);
        List<String> userNames = new List<String>();

        for(User user : users) {
            userNames.add(user.Name);
        }

        System.debug('UserNames: ' + userNames);
        return userNames;
    }
}