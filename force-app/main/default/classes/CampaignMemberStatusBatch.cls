public class CampaignMemberStatusBatch implements Database.Batchable<SObject> {
    private String queryWhereClause;
    
    public CampaignMemberStatusBatch() {}

    //customize where clause
    public CampaignMemberStatusBatch(String filter) {
        queryWhereClause = filter;
    }

    public Database.QueryLocator start(Database.BatchableContext bc) {
        String query = 'SELECT Id, ';
        if (CampaignMemberStatusSelector.hasCampaignRecordTypes) {
            query += 'RecordTypeId, ';
        }
        query += 'Type FROM Campaign';
        if (String.isNotBlank(queryWhereClause)) {
            query += ' ' + queryWhereClause;
        }
        System.debug('CampaignMemberStatusBatch query: ' + query);
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext BC, List<Campaign> campaigns) {
        (new CampaignMemberStatusService()).createCampaignMemberStatuses(campaigns);
    }

    public void finish(Database.BatchableContext BC) {}
}