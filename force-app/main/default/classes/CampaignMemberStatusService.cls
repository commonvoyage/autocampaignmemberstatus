public class CampaignMemberStatusService {

    CampaignMemberStatusSelector selector = new CampaignMemberStatusSelector();
    Map<Id, List<CampaignMemberStatus>> campaignMemberStatusesByCampaign;

    public CampaignMemberStatusService() {}

    public void createCampaignMemberStatuses(List<Campaign> campaigns) {
        campaignMemberStatusesByCampaign = selector.getCampaignMemberStatusesByCampaign(campaigns);
        System.debug('Existing campaign member statuses: ' + campaignMemberStatusesByCampaign);
        System.debug('Existing settings: ' + CampaignMemberStatusSelector.settings);
        
        //TODO: remove existing status values
        List<CampaignMemberStatus> statusForInsert = new List<CampaignMemberStatus>();
        List<CampaignMemberStatus> statusForDelete = new List<CampaignMemberStatus>();
        for (Campaign cam : campaigns) {
            System.debug('cms by campaign ' + campaignMemberStatusesByCampaign);
            if (selector.settingsByType.containsKey(cam.Type)) {
                statusForInsert.addAll(createStatuses(cam.Id, selector.settingsByType.get(cam.Type)));
            }
            if (CampaignMemberStatusSelector.hasCampaignRecordTypes) {
                String recTypeName = selector.recordTypeById.get((Id)cam.get('RecordTypeId'));
                System.debug('We have recordTypes! name: ' + recTypeName + 'Id: ' + cam.get('RecordTypeId') + 'recTypeById: ' + selector.recordTypeById);
                if (selector.settingsByRecordType.containsKey(recTypeName)) {
                    statusForInsert.addAll(createStatuses(cam.Id, selector.settingsByRecordType.get(recTypeName)));
                }
                if (selector.settingsByTypeAndRecordType.containsKey(cam.Type+recTypeName)) {
                    statusForInsert.addAll(createStatuses(cam.Id, selector.settingsByTypeAndRecordType.get(cam.Type+recTypeName)));
                }
            }
        }
        System.debug('Creating CampaignMemberStatus values: ' + statusForInsert);
        insert statusForInsert;
    }

    private List<CampaignMemberStatus> createStatuses(Id campaignId, List<CampaignMemberStatus__c> statuses) {
        List<CampaignMemberStatus> results = new List<CampaignMemberStatus>();
        Integer offset = getMaxSortOrder(campaignId)+1;
        for (CampaignMemberStatus__c status : statuses) {
            if (!statusAlreadyExists(campaignId, status.Campaign_Member_Status__c)) {
                CampaignMemberStatus cms = new CampaignMemberStatus(
                    CampaignId = campaignId,
                    Label = status.Campaign_Member_Status__c,
                    HasResponded = status.HasResponded__c,
                    IsDefault = status.IsDefault__c,
                    SortOrder = (Integer)status.SortOrder__c + offset
                );
                campaignMemberStatusesByCampaign.get(campaignId).add(cms);
                results.add(cms);
                offset = offset + 1;
            }
        }
        return results;
    }

    //does a status value already exist for a campaign?
    private Boolean statusAlreadyExists(Id campaignId, String status) {
        if (campaignMemberStatusesByCampaign.containsKey(campaignId)) {
            for (CampaignMemberStatus cms : campaignMemberStatusesByCampaign.get(campaignId)) {
                if (cms.Label == status) {
                    return true;
                }
            }
        }
        return false;
    }

    //gets the highest sort order so that we don't create overlapping numbers
    private Integer getMaxSortOrder(Id campaignId) {
        Integer max = 2;
        if (campaignMemberStatusesByCampaign.containsKey(campaignId)) {
            for (CampaignMemberStatus cms : campaignMemberStatusesByCampaign.get(campaignId)) {
                if (cms.SortOrder > max) {
                    max = cms.SortOrder;
                }
            }
        }
        return max;
    }
}