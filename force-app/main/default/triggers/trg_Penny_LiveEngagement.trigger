trigger trg_Penny_LiveEngagement on Live_Engagement__c (after insert, after update) 
{
    String strBotDevName = '';
    String strMessage = '';
    Integer maxSize = 500;
    Boolean ClearedCache = false;
    Cache.OrgPartition pCache;
    
    try
    {
       pCache = Cache.Org.getPartition('local.penny');
    }
    catch (Exception ex)
    {
        //No cache found
        system.debug('Not using cache. Please configure org cache partition local.penny if using for events with 30+ participants...');
    }
    
    for (Live_Engagement__c currentEngagement : trigger.new)
    {
        boolean changed = true;
        if (Trigger.isUpdate)
        {
            changed = !Trigger.oldMap.get(currentEngagement.Id).Active__c;
        }
        
        if (changed && currentEngagement.Active__c && currentEngagement.Send_Outbound_Message__c && String.isNotBlank(currentEngagement.Message__c))
        {
            strBotDevName = currentEngagement.Bot_Developer_Name__c;
            strMessage = currentEngagement.Message__c;
        }
        
        //See if we want to clear the cache
        if (pCache != null && currentEngagement.Active__c == changed && !ClearedCache)
        {
            PennyHelper.UpsertCache();
            ClearedCache = true;
        }
    }
    
    //Get engagements and subscribers
    List<Live_Engagement__c> objEngagements = new List<Live_Engagement__c>([Select ID, Name, Type__c, Send_Outbound_Message__c, Message__c, isNumeric_Response__c, Min_Value__c, Max_Value__c, Expected_Value__c, Winner__c FROM Live_Engagement__c WHERE Active__c =: TRUE AND Type__c != 'Notification' ORDER BY Name]);
    Map<Id,Contact> objSubscribers = new Map<Id,Contact>([SELECT ID, FirstName, Name FROM Contact WHERE Penny_PrimaryMessaging_User__c != null]);
    system.debug('Engagement Size: ' + objEngagements.size() + ' Contact Size: ' + objSubscribers.size());
    
    if (pCache != null)
    {
        //Write to cache
        pCache.put('EngagementIds', objEngagements);
        pCache.put('contacts', objSubscribers);
    }
    
    //Only continue if we have something to go on
    if (String.isNotBlank(strBotDevName) && String.isNotBlank(strMessage))
    {
        //Get all the Subscribers (Contacts) for this Bot
        List<Live_Engagement_Bot_Subscriber__c> objSubscribers = new List<Live_Engagement_Bot_Subscriber__c>([SELECT Id, Contact__c FROM Live_Engagement_Bot_Subscriber__c]); //WHERE Bot_Developer_Name__c =: strBotDevName]);
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
            
            if (objContacts.size() > 0 && Schema.sObjectType.Contact.isUpdateable() && Schema.sObjectType.Contact.fields.Penny_LOutboundMessage__c.isUpdateable())
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