@isTest
private class autoCampaignMemberStatusTest {

    @isTest(seeAllData=true)
    private static void test() {
        CampaignMemberStatusSelector.settings = new List<CampaignMemberStatus__c>{
            new CampaignMemberStatus__c(Campaign_Type__c = 'Conference', Campaign_Member_Status__c='Attended', IsDefault__c=false, SortOrder__c=1, HasResponded__c=true),
            new CampaignMemberStatus__c(Campaign_Type__c = 'Conference', Campaign_Member_Status__c='Declined', IsDefault__c=false, SortOrder__c=2, HasResponded__c=false),
            new CampaignMemberStatus__c(Campaign_Type__c = 'Conference', Campaign_Member_Status__c='No Show', IsDefault__c=false, SortOrder__c=3, HasResponded__c=false),
            new CampaignMemberStatus__c(Campaign_Type__c = 'Conference', Campaign_Member_Status__c='Another', IsDefault__c=false, SortOrder__c=4, HasResponded__c=true)
        };

        Test.startTest();
        insert new Campaign(Name='foo',Type='Conference',isActive=true);
        Database.executeBatch(new CampaignMemberStatusBatch());
        Test.stopTest();

        List<CampaignMemberStatus> statuses = [SELECT Id, CampaignId, Label, HasResponded, IsDefault, SortOrder FROM CampaignMemberStatus];
        system.debug(statuses);
        System.assert(statuses.size()>0, 'New status values should be created: ' + statuses);
    }
}