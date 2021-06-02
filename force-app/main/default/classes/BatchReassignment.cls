public with sharing class BatchReassignment implements Database.Batchable<SObject> {
    
    public final String query;
    public final String ownerId;

    public BatchReassignment(String query, String ownerId) {
        this.query = query;
        this.ownerId = ownerId;
    }

    public Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext bc, List<Lead> scope) {

        System.debug('ownerId: ' + ownerId);
        
        for (Lead item : scope) {
            System.debug('item: ' + item);
            item.OwnerId = ownerId;
        }

        update scope;
    }

    public void finish(Database.BatchableContext bc) {
        
    }
}