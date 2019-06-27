global class Penny_ProcessResponse 
{
    @InvocableMethod(label='Penny - Process Reponse')
    global static List<ProcessActionResponse> processResponse(List<ProcessActionRequest> requests) 
    {
        //Get all the return variables
        List<ProcessActionResponse> objResults = new List<ProcessActionResponse>();
        ProcessActionResponse objResult = new ProcessActionResponse();
        objResult.strResponse = PennyHelper.errorText;
        objResult.multiEngagement = false;
        objResult.transfer = '0';
        Live_Engagement__c currEngagement;
        Integer maxLen = 500;
        Cache.OrgPartition pCache = Cache.Org.getPartition('local.penny');
        
        try
        {
            if (requests != null && requests.size() > 0)
            {
                //Get the main request
                ProcessActionRequest currentRequest = requests[0];
                //Run all validations
                if (currentRequest.objContact != null && String.IsNotBlank(currentRequest.strBotName) && String.IsNotBlank(currentRequest.strUtterance))
                {
                    List<Live_Engagement__c> objEngagements;
                    //We are doing something
                    if (currentRequest.strEngagementId == '0')
                    {
                        //Filter list to only engagements that match this Bot
                        List<Live_Engagement__c> objMultiEngagements = (List<Live_Engagement__c>)pCache.get('EngagementIds');
                        objEngagements = PennyHelper.GetEngagementstoProcess(objMultiEngagements, currentRequest.strBotName, currentRequest.strUtterance);
                    }
                    else if (String.isNotBlank(currentRequest.strEngagementId) && currentRequest.strEngagementId != '-1')
                    {
                        //NEW CACHE &&&&&&&&&&&&&&&&&&&&&
                        List<Live_Engagement__c> objMultiEngagements = (List<Live_Engagement__c>)pCache.get('EngagementIds');
                        if (objMultiEngagements != null && objMultiEngagements.size() > 0)
                        {
                            for (Live_Engagement__c currentEngagement : objMultiEngagements)
                            {
                                if (currentEngagement.Id == currentRequest.strEngagementId)
                                {
                                    objEngagements = new List<Live_Engagement__c>();
                                    objEngagements.add(currentEngagement);
                                    break;
                                }
                            }
                        }
                    }
                    
                    //See the results
                    if (objEngagements == null || objEngagements.size() == 0)
                    {
                        //Nothing found
                        objResult.strResponse =  PennyHelper.noEngagementText;
                    }
                    else if (objEngagements.size() == 1)
                    {
                        //%%%%%% 1 engagement %%%%% MAIN LOOP
                        currEngagement = objEngagements[0];
                        
                        objResult.strResponse = PennyHelper.ProcessEngagementResponse(objEngagements, currEngagement, pCache, currentRequest.objContact, currentRequest.strUtterance, MaxLen, currentRequest.QRecordTypeID);
                        if (objResult.strResponse == PennyHelper.transferText)
                        {
                            objResult.transfer = '1';
                        }
                    }
                    else if (objEngagements.size() > 1)
                    {
                        //Multiple engagements
                        objResult.strResponse = 'Respond with an engagement number:';
                        objResult.multiEngagement = true;
                        for (integer i = 0; i < objEngagements.size(); i++)
                        {
                            objResult.strResponse += '\r\n' + String.valueOf(i + 1) + '-' + objEngagements[i].Name;
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
                objResult.strResponse += '\r\n\r\n' + currEngagement.Message__c;
                if (requests != null && requests.size() > 0 && requests[0].objContact != null)
                {
                    objResult.strResponse = objResult.strResponse.replace('{firstname}', (requests[0].objContact.firstName != null ? requests[0].objContact.firstName : requests[0].objContact.name));
                }
            }
        }
        
        objResults.add(objResult);
        return objResults;
    }
    
    global class ProcessActionRequest 
    {
        @InvocableVariable(required=false)
        global Contact objContact;
        @InvocableVariable(required=false)
        global String strBotName;
        @InvocableVariable(required=false)
        global String strUtterance;
        @InvocableVariable(required=false)
        global String strEngagementId;
        @InvocableVariable(required=false)
        global String QRecordTypeID;
    }
    
    global class ProcessActionResponse 
    {
        @InvocableVariable(required=false)
        global Boolean multiEngagement;
        @InvocableVariable(required=false)
        global String strResponse;
        @InvocableVariable(required=false)
        global String transfer;
    }
}