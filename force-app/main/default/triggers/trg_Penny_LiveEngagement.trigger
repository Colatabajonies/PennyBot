trigger trg_Penny_LiveEngagement on Live_Engagement__c (after insert, after update) 
{
    String strBotDevName = '';
    String strMessage = '';
    Integer maxSize = 500;
    Boolean ClearedCache = false;
    Cache.OrgPartition pCache = Cache.Org.getPartition('local.penny');
    
    for (Live_Engagement__c currentEngagement : trigger.new)
    {
        boolean changed = true;
        if (Trigger.isUpdate)
        {
            changed = !Trigger.oldMap.get(currentEngagement.Id).Active__c;
        }
        
        if (changed && currentEngagement.Active__c && currentEngagement.Send_Outbound_Message__c && String.isNotBlank(currentEngagement.Bot_Developer_Name__c) && String.isNotBlank(currentEngagement.Message__c))
        {
            strBotDevName = currentEngagement.Bot_Developer_Name__c;
            strMessage = currentEngagement.Message__c;
        }
        
        List<Live_Engagement__c> engIds = (List<Live_Engagement__c>)pCache.get('EngagementIds');
        if (currentEngagement.Active__c == changed && !ClearedCache)
        {
            PennyHelper.UpsertCache();
            ClearedCache = true;
        }
    }
    
    //Update the cache
    List<Live_Engagement__c> objEngagements = new List<Live_Engagement__c>([Select ID, Name, Type__c, Send_Outbound_Message__c, Message__c, isNumeric_Response__c, Min_Value__c, Max_Value__c, Bot_Developer_Name__c, Expected_Value__c, Winner__c FROM Live_Engagement__c WHERE Active__c =: TRUE AND Type__c != 'Notification' ORDER BY Name]);
    pCache.put('EngagementIds', objEngagements);
    Map<Id,Contact> objSubscribers = new Map<Id,Contact>([SELECT ID, FirstName, Name FROM Contact WHERE Penny_PrimaryMessaging_User__c != null]);
    pCache.put('contacts', objSubscribers);
    system.debug('Engagement Size: ' + objEngagements.size() + ' Contact Size: ' + objSubscribers.size());
    
    //Only continue if we have something to go on
    if (String.isNotBlank(strBotDevName) && String.isNotBlank(strMessage))
    {
        //Get all the Subscribers (Contacts) for this Bot
        List<Live_Engagement_Bot_Subscriber__c> objSubscribers = new List<Live_Engagement_Bot_Subscriber__c>([SELECT Id, Contact__c FROM Live_Engagement_Bot_Subscriber__c WHERE Bot_Developer_Name__c =: strBotDevName]);
        List<ID> objContactIDs = new List<ID>();

        
        //Loop through the subscribers
        for (Live_Engagement_Bot_Subscriber__c currentSubscriber : objSubscribers)
        {
            objContactIDs.add(currentSubscriber.Contact__c);
        }
        
        if (objContactIDs.size() > 0)
        {
            //Get the contacts
            List<Contact> objContacts = new List<Contact>([SELECT Id, Penny_LOutboundMessage__c, firstName, lastname, name FROM Contact WHERE ID in: objContactIDs]);
            
            if (objContacts.size() > 0)
            {
                //Loop through contacts to set the message
                for (Contact currentContact : objContacts)
                {
                    string displayname = String.isNotBlank(currentContact.firstName) ? currentContact.firstName : currentContact.Name;
                    String messageString = strMessage.replace('{firstname}', displayname);
                    if(messageString.length() > maxSize )
                    {
                        messageString = messageString.substring(0, maxSize);
                    }
                    currentContact.Penny_LOutboundMessage__c = messageString;
                }
                UPDATE objContacts;
            }
        }
    }
}