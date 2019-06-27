global class Penny_UpdateContact 
{
    @InvocableMethod(label='Penny - Update Contact')
    global static List<UContactActionResult> uContact(List<UContactActionRequest> requests) 
    {
        //Get all the return variables
        List<UContactActionResult> objResults = new List<UContactActionResult>();
        UContactActionResult objResult = new UContactActionResult();
        objResult.strResponse = 'Stay tuned, I\'ll be looking for your feedback soon.';
        objResult.objContact = new Contact();
        
        try
        {
            if (requests != null && requests.size() > 0 && String.isNotBlank(requests[0].strBotName))
            {
                //Get the main request
                UContactActionRequest currentRequest = requests[0];
                if (currentRequest.objContact != null && String.isNotBlank(currentRequest.strFirstName) && String.isNotBlank(currentRequest.strLastName))
                {
                    objResult.objContact = currentRequest.objContact;
                    
                    //Peform the update
                    currentRequest.objContact.FirstName = currentRequest.strFirstName;
                    currentRequest.objContact.LastName = currentRequest.strLastName;
                    UPDATE currentRequest.objContact;
                    objResult.objContact = currentRequest.objContact;
                }
                
                //Now get an active Live Engagement
                List<Live_Engagement__c> objEngagements = new List<Live_Engagement__c>([Select ID, Message__c FROM Live_Engagement__c WHERE Active__c =: TRUE AND Bot_Developer_Name__c =: currentRequest.strBotName AND Type__c != 'Notification']);
                if (objEngagements != null && objEngagements.size() == 1 && String.isNotBlank(objEngagements[0].Message__c))
                {
                    //set the message
                    objResult.strResponse = objEngagements[0].Message__c.replace('{firstname}', (objResult.objContact.firstName != null ? objResult.objContact.firstName : objResult.objContact.name));
                }
            }
        }
        catch(Exception ex)
        {
			objResult.strResponse = 'Uh oh. There was a problem updating your info.';            
        }
        
        objResults.add(objResult);
        return objResults;
    }
    
    global class UContactActionRequest 
    {
        @InvocableVariable(required=false)
        global Contact objContact;
        @InvocableVariable(required=false)
        global String strFirstName;
        @InvocableVariable(required=false)
        global String strLastName;
        @InvocableVariable(required=false)
        global String strBotName;
    }
    global class UContactActionResult
    {
        @InvocableVariable(required=false)
        global String strResponse;
        @InvocableVariable(required=false)
        global Contact objContact;
    }
}