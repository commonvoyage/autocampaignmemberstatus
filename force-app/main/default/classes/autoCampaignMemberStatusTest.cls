@isTest
private class autoCampaignMemberStatusTest {

    //seeAllData is necessary to for tests to see CampaignMemberStatus records
    @isTest(seeAllData=true)
    private static void typeOnly() {
        CampaignMemberStatusSelector.settings = new List<CampaignMemberStatus__c>{};

        Campaign conference = new Campaign(Name='foo',Type='Conference',isActive=true);
        insert conference;

        List<CampaignMemberStatus> statuses = [SELECT Id, CampaignId, Label, HasResponded, IsDefault, SortOrder FROM CampaignMemberStatus WHERE CampaignId = :conference.Id];
        system.debug(statuses);

        Integer existingStatuses = statuses.size();

        CampaignMemberStatusSelector.settings = new List<CampaignMemberStatus__c>{
            new CampaignMemberStatus__c(Campaign_Type__c = 'Conference', Campaign_Member_Status__c='Attended', IsDefault__c=false, SortOrder__c=1, HasResponded__c=true),
            new CampaignMemberStatus__c(Campaign_Type__c = 'Conference', Campaign_Member_Status__c='Declined', IsDefault__c=false, SortOrder__c=2, HasResponded__c=false),
            new CampaignMemberStatus__c(Campaign_Type__c = 'Conference', Campaign_Member_Status__c='No Show', IsDefault__c=false, SortOrder__c=3, HasResponded__c=false),
            new CampaignMemberStatus__c(Campaign_Type__c = 'Conference', Campaign_Member_Status__c='Another', IsDefault__c=false, SortOrder__c=4, HasResponded__c=true)
        };

        Test.startTest();
        Database.executeBatch(new CampaignMemberStatusBatch('WHERE Id = \''+conference.Id+'\''));
        Test.stopTest();

        statuses = [SELECT Id, CampaignId, Label, HasResponded, IsDefault, SortOrder FROM CampaignMemberStatus WHERE CampaignId = :conference.Id];

        System.assertEquals(existingStatuses+4, statuses.size(), 'Four new status values should be created: ' + statuses);

    }

    @isTest(seeAllData=true)
    private static void recordTypeOnly() {
        //only test if this org has record types on Campaign
        if (!CampaignMemberStatusSelector.hasCampaignRecordTypes) {
            return;
        }
        CampaignMemberStatusSelector selector = new CampaignMemberStatusSelector();
        String defaultRecTypeName = selector.recordTypeById.get(selector.defaultRecordTypeId);

        CampaignMemberStatusSelector.settings = new List<CampaignMemberStatus__c>{};

        Campaign conference = new Campaign(Name='foo',Type='Conference',isActive=true);
        conference.put('RecordTypeId',selector.defaultRecordTypeId);
        insert conference;

        List<CampaignMemberStatus> statuses = [SELECT Id, CampaignId, Label, HasResponded, IsDefault, SortOrder FROM CampaignMemberStatus WHERE CampaignId = :conference.Id];
        system.debug(statuses);

        Integer existingStatuses = statuses.size();

        CampaignMemberStatusSelector.settings = new List<CampaignMemberStatus__c>{
            new CampaignMemberStatus__c(Campaign_Record_Type_Name__c = defaultRecTypeName, Campaign_Member_Status__c='Donated', IsDefault__c=false, SortOrder__c=4, HasResponded__c=true),
            new CampaignMemberStatus__c(Campaign_Record_Type_Name__c = defaultRecTypeName, Campaign_Member_Status__c='Another', IsDefault__c=false, SortOrder__c=5, HasResponded__c=true)
        };

        Test.startTest();
        Database.executeBatch(new CampaignMemberStatusBatch('WHERE Id = \''+conference.Id+'\''));
        Test.stopTest();

        statuses = [SELECT Id, CampaignId, Label, HasResponded, IsDefault, SortOrder FROM CampaignMemberStatus WHERE CampaignId = :conference.Id];
        System.assertEquals(existingStatuses+2, statuses.size(), 'Two new statuses should be created: ' + statuses);
    }

    @isTest(seeAllData=true)
    private static void typeAndRecordType() {
        //only test if this org has record types on Campaign
        if (!CampaignMemberStatusSelector.hasCampaignRecordTypes) {
            return;
        }
        CampaignMemberStatusSelector selector = new CampaignMemberStatusSelector();
        String defaultRecTypeName = selector.recordTypeById.get(selector.defaultRecordTypeId);

        CampaignMemberStatusSelector.settings = new List<CampaignMemberStatus__c>{};

        Campaign conference = new Campaign(Name='foo',Type='Conference',isActive=true);
        conference.put('RecordTypeId',selector.defaultRecordTypeId);
        insert conference;

        List<CampaignMemberStatus> statuses = [SELECT Id, CampaignId, Label, HasResponded, IsDefault, SortOrder FROM CampaignMemberStatus WHERE CampaignId = :conference.Id];
        system.debug(statuses);

        Integer existingStatuses = statuses.size();

        CampaignMemberStatusSelector.settings = new List<CampaignMemberStatus__c>{
            new CampaignMemberStatus__c(Campaign_Record_Type_Name__c = defaultRecTypeName, Campaign_Type__c = 'Conference', Campaign_Member_Status__c='Donated', IsDefault__c=false, SortOrder__c=1, HasResponded__c=true),
            new CampaignMemberStatus__c(Campaign_Record_Type_Name__c = defaultRecTypeName, Campaign_Type__c = 'Conference', Campaign_Member_Status__c='Another', IsDefault__c=false, SortOrder__c=1, HasResponded__c=true)
        };

        Test.startTest();
        Database.executeBatch(new CampaignMemberStatusBatch('WHERE Id = \''+conference.Id+'\''));
        Test.stopTest();

        statuses = [SELECT Id, CampaignId, Label, HasResponded, IsDefault, SortOrder FROM CampaignMemberStatus WHERE CampaignId = :conference.Id];
        System.assertEquals(existingStatuses+2, statuses.size(), 'Two new statuses should be created: ' + statuses);
    }
}