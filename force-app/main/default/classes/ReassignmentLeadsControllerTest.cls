@isTest
private class ReassignmentLeadsControllerTest {
    
    @TestSetup
    private static void setup() {

        Region__c region = new Region__c(Name = 'APAC');
        insert region;

        Country__c country1 = new Country__c(Name = 'China', Region__c = region.Id);
        Country__c country2 = new Country__c(Name = 'Japan', Region__c = region.Id);

        insert country1;
        insert country2;

        Profile profile = [SELECT Id FROM Profile WHERE Name = 'Standard User'][0];
        List<User> sourceUsers = new List<User>();
        
        for(Integer i = 0; i < 2; i++) {
            Blob b = Crypto.GenerateAESKey(128);
            String hex = EncodingUtil.ConvertTohex(b);
            String uid = hex.SubString(0,8);
            User user = new User(
                Alias = uid,
                Email = uid + '@gmail.com', 
                EmailEncodingKey = 'UTF-8',
                LastName = ('Test User ' + i),
                LanguageLocaleKey = 'en_US', 
                LocaleSidKey = 'en_US',
                ProfileId = profile.Id,
                TimeZoneSidKey = 'America/New_York',
                UserName = uid + '@testmail.ru');

            sourceUsers.add(user);
        }

        insert sourceUsers;

        insert new Lead(
            LastName = 'Test Name',
            Company = 'Test Company',
            Status = 'Open - Not Contacted',
            Region__c = region.Id,
            Country__c = country1.Id);
    }

    @isTest
    static void testGetDependentMap() {
        Region__c region = [SELECT Id, Name FROM Region__c][0];
        List<Country__c> countries = [SELECT Id, Name FROM Country__c];
        List<String> countryNames = new List<String>();

        for(Country__c country : countries) {
            countryNames.add(country.Name);
        }

        Map<String, List<String>> sourceMap = new Map<String,List<String>>();
        sourceMap.put(region.Name, countryNames);
        System.debug('sourceMap: ' + sourceMap);

        Map<String, List<String>> resultMap = ReassignmentLeadsController.getDependentMap();
        System.debug('resultMap: ' + resultMap);

        System.assertEquals(sourceMap, resultMap);
    }

    @isTest
    static void testGetOwnerNames() {

        List<String> resultUserNames = ReassignmentLeadsController.getOwnerNames();
        System.debug('resultUserNames: ' + resultUserNames);

        for(String userName : resultUserNames) {
            if(userName.contains('testmail')) {
                System.assertEquals(userName.contains('Test User'), true);
            }
        }
    }

    @isTest
    static void testGetStatus() {
        List<String> testStatuses = ReassignmentLeadsController.getStatus();

        System.assertEquals(testStatuses.contains('Open - Not Contacted'), true);
        System.assertEquals(testStatuses.contains('Working - Contacted'), true);
        System.assertEquals(testStatuses.contains('Closed - Converted'), true);
        System.assertEquals(testStatuses.contains('Closed - Not Converted'), true);
        System.assertEquals(testStatuses.size(), 4);
    }

    @isTest
    static void testSetLeads() {
        Region__c region = [SELECT Id, Name FROM Region__c][0];
        List<Country__c> countries = [SELECT Id, Name FROM Country__c];
        String stringCountryNames = '';
        Lead ld = [SELECT Id, LastName, Status, OwnerId, Region__c, Country__c FROM Lead][0];
        User user = [SELECT Id, Name FROM User WHERE Id =: ld.OwnerId];
        System.debug('User before update from test: ' + user);

        for(Country__c country : countries) {
            stringCountryNames += country.Name + ';';
        }

        stringCountryNames = stringCountryNames.removeEnd(';');

        String stringStatuses = 'Open - Not Contacted;' +
                                'Working - Contacted;' +
                                'Closed - Converted;' +
                                'Closed - Not Converted';

        String ownerName = 'Test User 0';

        Test.startTest();
        ReassignmentLeadsController.setLeads(region.Name, stringCountryNames, stringStatuses, 'Test User 0');
        Test.stopTest();
        
        System.debug('region.Name from test: ' + region.Name);
        System.debug('stringCountryNames from test: ' + stringCountryNames);
        System.debug('stringStatuses from test: ' + stringStatuses);
        System.debug('ownerName from test: ' + ownerName);

        Lead updatedLead = [SELECT Id, LastName, OwnerId FROM Lead][0];
        System.debug('updatedLead from test: ' + updatedLead);
        System.debug('updatedLead.OwnerId from test: ' + updatedLead.OwnerId);
        User updatedUser = [SELECT Id, Name FROM User WHERE Id =: updatedLead.OwnerId];
        System.debug('user after update from test: ' + updatedUser);
        
        System.assertEquals(updatedUser.Name, 'Test User 0');
    }
}