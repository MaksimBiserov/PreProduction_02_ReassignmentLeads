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
}