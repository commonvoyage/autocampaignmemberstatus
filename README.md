# AAuto Campaign Member Status

We were fans of the once-free app that helped you automagically create Campaign Member Status values, and sad when it became a paid app, so we created our own vesion! We promise that this app will be free forever. We'll also try to keep it working :)

This package will create new status values for campaigns. Decide which campaigns get which values by Campaign Type, Campaign Record Type, or both. Configure which values to create through the Campaign Member Status custom setting.

Once configured, each new campaign that matches the configuration will get new status values automatically on creation.

You can also create them for all existing campaigns by running this command in Developer Console > Debug > Open Execute Anonymous Window:

`Database.executeBatch(new AAuto_CampaignMemberStatusBatch());`

To create status values on a subset of existing campaigns, you can add a SOQL WHERE clause:

`Database.executeBatch(new AAuto_CampaignMemberStatusBatch('WHERE Type = \'Conference\''));`

Install this managed package here: https://login.salesforce.com/packaging/installPackage.apexp?p0=04t4R000001hhQL

Or just deploy this code unmanaged if you want to modify it.

We love open source software at Common Voyage. Feel free to create issues in this repository, or submit pull requests!
