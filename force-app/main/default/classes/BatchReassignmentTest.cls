@isTest
private class BatchReassignmentTest {

    @TestSetup
    private static void setup() {
        Region__c region = new Region__c(Name = 'APAC');
        insert region;

        Country__c country = new Country__c(Name = 'China', Region__c = region.Id);
        insert country;

        Profile profile = [SELECT Id FROM Profile WHERE Name = 'Standard User'][0];
        Blob b = Crypto.GenerateAESKey(128);
        String hex = EncodingUtil.ConvertTohex(b);
        String uid = hex.SubString(0,8);

        insert new User(
            Alias = uid,
            Email = uid + '@gmail.com', 
            EmailEncodingKey = 'UTF-8',
            LastName = ('Test User 0'),
            LanguageLocaleKey = 'en_US', 
            LocaleSidKey = 'en_US',
            ProfileId = profile.Id,
            TimeZoneSidKey = 'America/New_York',
            UserName = uid + '@testmail.ru');

        insert new Lead(
            LastName = 'Test Name',
            Company = 'Test Company',
            Status = 'Open - Not Contacted',
            Region__c = region.Id,
            Country__c = country.Id);
    }

    @isTest
    static void testExecute() {
        Region__c region = [SELECT Id, Name FROM Region__c][0];
        Country__c country = [SELECT Id, Name FROM Country__c][0];
        Lead ld = [SELECT Id, LastName, Status, OwnerId, Region__c, Country__c FROM Lead][0];
        System.debug('Lead before update from batch: ' + ld);

        String query = 'SELECT Id, Name FROM Lead WHERE Region__c = \'' +
                        region.Id + '\' AND Country__c = \'' +
                        country.Id + '\' AND (Status = \'Open - Not Contacted\' OR Status = \'Working - Contacted\')';
        
        System.debug('query from batch: ' + query);
        
        User user = [SELECT Id, Name FROM User WHERE LastName =: 'Test User 0'][0];
        System.debug('Inserted user from batch: ' + user.Id);

        Test.startTest();
        BatchReassignment batch = new BatchReassignment(query, user.Id);
        Database.executeBatch(batch);
        Test.stopTest();

        Lead updatedLead = [SELECT Id, LastName, OwnerId FROM Lead][0];
        System.debug('updatedLead from batch: ' + updatedLead);

        User updatedUser = [SELECT Id, Name FROM User WHERE Id =: updatedLead.OwnerId];
        System.debug('updatedUser from batch: ' + updatedUser);

        System.assertEquals('Test User 0', updatedUser.Name);
    }
}