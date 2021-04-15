public class CampaignMemberStatusSelector {
    //Uses dynamic references to Campaign.RecordTypeId in order to function in orgs where they haven't been added. This shows whether they exist or not.
    public static Boolean hasCampaignRecordTypes = Schema.SObjectType.Campaign.fields.getMap().containsKey('RecordTypeId');
    //Querying the custom object for easy sorting
    public static List<CampaignMemberStatus__c> settings = [SELECT Campaign_Member_Status__c, Campaign_Record_Type_Name__c, Campaign_Type__c, IsDefault__c, HasResponded__c, SortOrder__c FROM CampaignMemberStatus__c ORDER BY SortOrder__c ASC];
    public Map<String, List<CampaignMemberStatus__c>> settingsByType;
    public Map<String, List<CampaignMemberStatus__c>> settingsByRecordType;
    public Map<String, List<CampaignMemberStatus__c>> settingsByTypeAndRecordType;
    public Map<Id, String> recordTypeById;
    public Id defaultRecordTypeId;

    //constructor gathers status values from settings
    public CampaignMemberStatusSelector() {
        settingsByType = new Map<String, List<CampaignMemberStatus__c>>();
        settingsByRecordType = new Map<String, List<CampaignMemberStatus__c>>();
        settingsByTypeAndRecordType = new Map<String, List<CampaignMemberStatus__c>>();
        recordTypeById = new Map<Id, String>();

        for (CampaignMemberStatus__c setting : settings) {
            System.debug('Processing setting: ' + setting);
            if (String.isBlank(setting.Campaign_Member_Status__c)) {
                continue;
            }
            if (setting.Campaign_Type__c != null && setting.Campaign_Record_Type_Name__c == null) {
                if (!settingsByType.containsKey(setting.Campaign_Type__c)) {
                    settingsByType.put(setting.Campaign_Type__c, new List<CampaignMemberStatus__c>());
                }
                settingsByType.get(setting.Campaign_Type__c).add(setting);
            }
            if (hasCampaignRecordTypes && setting.Campaign_Type__c == null && setting.Campaign_Record_Type_Name__c != null) {
                
                if (!settingsByRecordType.containsKey(setting.Campaign_Record_Type_Name__c)) {
                    settingsByRecordType.put(setting.Campaign_Record_Type_Name__c, new List<CampaignMemberStatus__c>());
                }
                settingsByRecordType.get(setting.Campaign_Record_Type_Name__c).add(setting);
            }
            if (hasCampaignRecordTypes && setting.Campaign_Type__c != null && setting.Campaign_Record_Type_Name__c != null) {
                String key = setting.Campaign_Type__c+setting.Campaign_Record_Type_Name__c;
                if (!settingsByTypeAndRecordType.containsKey(key)) {
                    settingsByTypeAndRecordType.put(key, new List<CampaignMemberStatus__c>());
                }
                settingsByTypeAndRecordType.get(key).add(setting);
            }
        }
        Map<String, Schema.RecordTypeInfo> recordTypesByName = Schema.SObjectType.Campaign.getRecordTypeInfosByName();
        System.debug('has RecordTypes? ' + hasCampaignRecordTypes + ' Names: ' + recordTypesByName);
        for (String recordTypeName : recordTypesByName.keySet()) {
            System.debug('Adding name ' + recordTypeName + 'with Id: ' + recordTypesByName.get(recordTypeName).getRecordTypeId());
            if (recordTypesByName.containsKey(recordTypeName) && !recordTypesByName.get(recordTypeName).isMaster()) {
                Schema.RecordTypeInfo info = recordTypesByName.get(recordTypeName);
                recordTypeById.put(info.getRecordTypeId(), recordTypeName);
                if (info.isDefaultRecordTypeMapping()) {
                    defaultRecordTypeId = info.getRecordTypeId();
                }
            }
        }
    }

    public Map<Id, List<CampaignMemberStatus>> getCampaignMemberStatusesByCampaign(List<Campaign> campaigns) {
        Map<Id, List<CampaignMemberStatus>> results = new Map<Id, List<CampaignMemberStatus>>();
        for (CampaignMemberStatus status : [SELECT CampaignId, Label, HasResponded, IsDefault, SortOrder FROM CampaignMemberStatus WHERE CampaignId IN :campaigns]) {
            if (!results.containsKey(status.CampaignId)) {
                results.put(status.CampaignId, new List<CampaignMemberStatus>());
            }
            results.get(status.CampaignId).add(status);
        }
        return results;
    }
}