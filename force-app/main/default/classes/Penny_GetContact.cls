global class Penny_GetContact 
{    
    @InvocableMethod(label='Penny - Get Contact')
    global static List<GetContactActionResponse> getContact(List<GetContactActionRequest> requests) 
    {
        //Get all the return variables
        List<GetContactActionResponse> objResults = new List<GetContactActionResponse>();
        GetContactActionResponse objResult = new GetContactActionResponse();
        objResult.boolContactCreated = false;
        objResult.objContact = null;
        
        try
        {
            if (requests != null && requests.size() > 0)
            {
                //Get the main request
                GetContactActionRequest currentRequest = requests[0];
                //Run all validations
                if (String.isNotBlank(currentRequest.sessionId))
                {
                    List<MessagingSession> objSessions = new List<MessagingSession>([Select ID, EndUserContactId, MessagingEndUserId, MessagingEndUser.ContactId, MessagingEndUser.Name, MessagingEndUser.MessageType, MessagingEndUser.MessagingPlatformKey, MessagingEndUser.ProfilePictureURL FROM MessagingSession WHERE Id =: currentRequest.sessionId LIMIT 1]);
                    if (objSessions != null && objSessions.size() > 0 && objSessions[0].MessagingEndUser.ContactId != null)
                    {
                        //Return the contact
                        List<Contact> objContacts = new List<Contact>([SELECT ID, Name, FirstName FROM Contact WHERE ID =: objSessions[0].MessagingEndUser.ContactId LIMIT 1]);
                        if (objContacts != null && objContacts.size() > 0)
                        {
                            objResult.objContact = objContacts[0];
                        }
                    }
                    else if (objSessions != null && objSessions.size() > 0)
                    {
                        //No Contact
                        //Create one
                        Contact myContact = new Contact();
                        myContact.LastName = objSessions[0].MessagingEndUser.Name;
                        myContact.AccountId = currentRequest.accountID;
                        myContact.Penny_PrimaryMessaging_User__c = objSessions[0].MessagingEndUserId;
                        if (objSessions[0].MessagingEndUser.MessageType == 'Facebook')
                        {
                            //myContact.Facebook_Persona_ID__c = objSessions[0].MessagingEndUser.MessagingPlatformKey;
                            //myContact.Facebook_Picture__c = objSessions[0].MessagingEndUser.ProfilePictureURL;
                        }
                        else
                        {
                            myContact.MobilePhone = objSessions[0].MessagingEndUser.MessagingPlatformKey;
                        }
                        
                        INSERT myContact;
                        objResult.boolContactCreated = true;
                        objResult.objContact = myContact;
                        
                        //Now update the messaging user
                        List<MessagingEndUser> objUsers = new List<MessagingEndUser>([SELECT ID, ContactID FROM MessagingEndUser WHERE id=: objSessions[0].MessagingEndUserId LIMIT 1]);
                        if (objUsers != null && objUsers.size()>0)
                        {
                            objUsers[0].ContactID = myContact.Id;
                            UPDATE objUsers;
                        }
                    }
                    
                    //Finally check subscribe
                    if (objResult.objContact != null)
                    {
                        List<Live_Engagement_Bot_Subscriber__c> objSubscriptions = new List<Live_Engagement_Bot_Subscriber__c>([SELECT ID FROM Live_Engagement_Bot_Subscriber__c WHERE Contact__c =: objResult.objContact.Id AND Bot_Developer_Name__c =: currentRequest.strBotName LIMIT 1]);
                        if (objSubscriptions == null || objSubscriptions.size() == 0)
                        {
                            //We need to insert
                            Live_Engagement_Bot_Subscriber__c newSub = new Live_Engagement_Bot_Subscriber__c();
                            newSub.Contact__c = objResult.objContact.Id;
                            newSub.Bot_Developer_Name__c = currentRequest.strBotName;
                            INSERT newSub;
                        }
                    }
                }
            }
        }
        catch(Exception ex)
        {
            //What to do here?
        }
        
        objResults.add(objResult);
        return objResults;
    }
    
    global class GetContactActionRequest 
    {
        @InvocableVariable(required=false)
        global String strBotName;
        @InvocableVariable(required=false)
        global String sessionId;
        @InvocableVariable(required=false)
        global String accountID;
    }
    
    global class GetContactActionResponse 
    {
        @InvocableVariable(required=false)
        global Contact objContact;
        @InvocableVariable(required=false)
        global Boolean boolContactCreated;
    }
}