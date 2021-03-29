trigger Campaign on Campaign (after insert) {
    try{
        (new CampaignMemberStatusService()).createCampaignMemberStatuses((List<Campaign>)trigger.new);
    } catch (Exception ex) {
        //TODO NPSP error
        //TODO send error email to active user
    }
}