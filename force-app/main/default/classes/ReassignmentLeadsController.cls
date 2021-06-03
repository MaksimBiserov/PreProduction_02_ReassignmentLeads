public with sharing class ReassignmentLeadsController {
    
    private static final string objectApiName = 'Lead';
    private static final string fieldApiName = 'Status';

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

    @AuraEnabled
    public static List<String> getStatus() {
        List<String> picklistValues = new List<String>();
        Schema.SObjectType targetType = Schema.getGlobalDescribe().get(objectApiName);
        SObject objectName = targetType.newSObject();
        Schema.SObjectType sobjectType = objectName.getSObjectType();
        Schema.DescribeSObjectResult sobjectDescribe = sobjectType.getDescribe();
        Map<String, Schema.SObjectField> fieldMap = sobjectDescribe.fields.getMap();
        List<Schema.PicklistEntry> picklistEntries = fieldMap.get(fieldApiName).getDescribe().getPickListValues();
        
        for (Schema.PicklistEntry item : picklistEntries) {
            picklistValues.add(item.getValue());
            System.debug('Item: ' + item.getValue());
        }

        System.debug('picklistValues: ' + picklistValues);
        return picklistValues;
    }

    @AuraEnabled
    public static void setLeads(String regionName, String stringCountryNames,
                                String stringStatuses, String ownerName) {
        
        System.debug('regionName: ' + regionName);
        System.debug('stringCountryNames: ' + stringCountryNames);
        System.debug('stringStatuses: ' + stringStatuses);
        System.debug('ownerName: ' + ownerName);

        List<String> countryNames = stringCountryNames.split(';');
        System.debug('countryNames: ' + countryNames);

        List<String> statuses = stringStatuses.split(';');
        System.debug('statuses: ' + statuses);

        Region__c region = [SELECT Id FROM Region__c WHERE Name =: regionName][0];
        List<Country__c> countries = [SELECT Id FROM Country__c WHERE Name IN: countryNames];
        String queryCountries = 'Country__c = ';
        String queryStatuses = 'Status = ';

        for(Country__c country : countries) {
            System.debug('country Id: ' + country.Id);
            queryCountries += '\'' + country.Id + '\' OR Country__c = ';
        }

        queryCountries = queryCountries.removeEnd(' OR Country__c = ');
        System.debug('queryCountries: ' + queryCountries);

        for(String status : statuses) {
            System.debug('status: ' + status);
            queryStatuses += '\'' + status + '\' OR Status = ';
        }

        queryStatuses = queryStatuses.removeEnd(' OR Status = ');
        System.debug('queryStatuses: ' + queryStatuses);

        String query = 'SELECT Id, Name FROM Lead WHERE Region__c = \'' +
                        region.Id +
                        '\' AND (' +
                        queryCountries +
                        ') AND (' +
                        queryStatuses + ')';

        System.debug('query: ' + query);

        User user = [SELECT Id, Name FROM User WHERE Name =: ownerName][0];

        BatchReassignment batch = new BatchReassignment(query, user.Id);
        Database.executeBatch(batch);
    }
}