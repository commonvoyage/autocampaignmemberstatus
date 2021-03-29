public class CampaignMemberStatusSelector {
    //Uses dynamic references to Campaign.RecordTypeId in order to function in orgs where they haven't been added. This shows whether they exist or not.
    public static Boolean hasCampaignRecordTypes = Schema.SObjectType.Campaign.fields.getMap().containsKey('RecordTypeId');
    public static List<CampaignMemberStatus__c> settings = CampaignMemberStatus__c.getAll().values();
    public Map<String, List<CampaignMemberStatus__c>> settingsByType;
    public Map<String, List<CampaignMemberStatus__c>> settingsByRecordType;
    public Map<String, List<CampaignMemberStatus__c>> settingsByTypeAndRecordType;
    public Map<Id, String> recordTypeById;

    //constructor gathers status values from settings
    public CampaignMemberStatusSelector() {
        settingsByType = new Map<String, List<CampaignMemberStatus__c>>();
        settingsByRecordType = new Map<String, List<CampaignMemberStatus__c>>();
        settingsByTypeAndRecordType = new Map<String, List<CampaignMemberStatus__c>>();
        recordTypeById = new Map<Id, String>();

        for (CampaignMemberStatus__c setting : settings) {
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
        for (String recordTypeName : recordTypesByName.keySet()) {
            if (recordTypesByName.containsKey('RecordTypeName')) {
                recordTypeById.put(recordTypesByName.get('RecordTypeName').getRecordTypeId(), recordTypeName);
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