global class Penny_ProcessMultiEngage 
{
    @InvocableMethod(label='Penny - Process MultiEngagement Response')
    global static List<MultiActionResponse> processResponse(List<MultiActionRequest> requests) 
    {
        //Get all the return variables
        List<MultiActionResponse> objResults = new List<MultiActionResponse>();
        MultiActionResponse objResult = new MultiActionResponse();
        objResult.strResponse = PennyHelper.errorText;
        objResult.transfer = '0';
        Live_Engagement__c currEngagement;
        Cache.OrgPartition pCache = Cache.Org.getPartition('local.penny');
        Integer maxLen = 500;
        
        try
        {
            if (requests != null && requests.size() > 0)
            {
                //Get the main request
                MultiActionRequest currentRequest = requests[0];
                //Run all validations
                if (currentRequest.objContact != null && String.IsNotBlank(currentRequest.strBotName) && String.IsNotBlank(currentRequest.strUtterance) && currentRequest.dbEngagementNum > 0)
                {
                    //NEW CACHE &&&&&&&&&&&&&&&&&&&&&
                    List<Live_Engagement__c> objMultiEngagements = (List<Live_Engagement__c>)pCache.get('EngagementIds');
                    List<Live_Engagement__c> objEngagements = PennyHelper.GetEngagementstoProcess(objMultiEngagements, currentRequest.strBotName, currentRequest.strUtterance);
                    
                    //List<Live_Engagement__c> objEngagements = new List<Live_Engagement__c>([Select ID, Name, Type__c, Send_Outbound_Message__c, Message__c, isNumeric_Response__c, Min_Value__c, Max_Value__c FROM Live_Engagement__c WHERE Active__c =: TRUE AND Bot_Developer_Name__c =: currentRequest.strBotName AND Type__c != 'Notification' ORDER BY Name]);
                    if (objEngagements != null || objEngagements.size() > 0 && currentRequest.dbEngagementNum <= objEngagements.size())
                    {
                        //We can rock and roll!
                        currEngagement = objEngagements[Integer.valueof(currentRequest.dbEngagementNum) - 1];
                        
                        objResult.strResponse = PennyHelper.ProcessEngagementResponse(objEngagements, currEngagement, pCache, currentRequest.objContact, currentRequest.strUtterance, MaxLen, currentRequest.QRecordTypeID);
                        if (objResult.strResponse == PennyHelper.transferText)
                        {
                            objResult.transfer = '1';
                        }
                    }  
                }
            }
        }
        catch(Exception ex)
        {
            //What to do here?
            if (currEngagement != null && String.isNotBlank(currEngagement.Message__c))
            {
                objResult.strResponse += '\r\n' + currEngagement.Message__c;
            }
        }
        
        objResults.add(objResult);
        return objResults;
    }
    
    global class MultiActionRequest 
    {
        @InvocableVariable(required=false)
        global Contact objContact;
        @InvocableVariable(required=false)
        global String strBotName;
        @InvocableVariable(required=false)
        global String strUtterance;
        @InvocableVariable(required=false)
        global Double dbEngagementNum;
        @InvocableVariable(required=false)
        global String QRecordTypeID;
    }
    
    global class MultiActionResponse 
    {
        @InvocableVariable(required=false)
        global String strResponse;
        @InvocableVariable(required=false)
        global String transfer;
    }
}