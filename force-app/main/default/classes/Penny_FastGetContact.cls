global class Penny_FastGetContact 
{
    @InvocableMethod(label='Penny - Fast Get Contact')
    global static List<fContactActionResult> uContact(List<fContactActionRequest> requests) 
    {
        //Get all the return variables
        List<fContactActionResult> objResults = new List<fContactActionResult>();
        fContactActionResult objResult = new fContactActionResult();
        objResult.objContact = null;
        Cache.OrgPartition pCache = Cache.Org.getPartition('local.penny');
        
        try
        {
            if (requests != null && requests.size() > 0 && String.isNotBlank(requests[0].contactId))
            {
                Id theContactID = requests[0].contactId;
                //first try to get the cache
                Map<Id,Contact> myContacts = (Map<Id,Contact>)pCache.get('contacts');
                if (myContacts != null && myContacts.size() > 0)
                {
                    objResult.objContact = myContacts.get(theContactID);
                }
                if (objResult.objContact == null)
                {
                    //we need to pull from the DB
                    List<Contact> lstContacts = new List<Contact>([SELECT ID, FirstName, Name FROM Contact WHERE ID =: theContactID LIMIT 1]);
                    
                    if (lstContacts != null && lstContacts.size() > 0)
                    {
                        objResult.objContact = lstContacts[0];
                    }
                }
                
                List<Live_Engagement_Bot_Subscriber__c> objSubscriptions = new List<Live_Engagement_Bot_Subscriber__c>([SELECT ID FROM Live_Engagement_Bot_Subscriber__c WHERE Contact__c =: objResult.objContact.Id AND Bot_Developer_Name__c =: requests[0].botDevName LIMIT 1]);
                if (objSubscriptions == null || objSubscriptions.size() == 0)
                {
                    //We need to insert
                    Live_Engagement_Bot_Subscriber__c newSub = new Live_Engagement_Bot_Subscriber__c();
                    newSub.Contact__c = objResult.objContact.Id;
                    newSub.Bot_Developer_Name__c = requests[0].botDevName;
                    INSERT newSub;
                }
            }
        }
        catch(Exception ex)
        {
			            
        }
        
        objResults.add(objResult);
        return objResults;
    }
    
    global class fContactActionRequest
    {
        @InvocableVariable(required=false)
        global Id contactId;
        @InvocableVariable(required=false)
        global string botDevName;
    }
    global class fContactActionResult
    {
        @InvocableVariable(required=false)
        global Contact objContact;
    }
}