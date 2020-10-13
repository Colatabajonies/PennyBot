public class PennyPollData_ctr 
{
    @AuraEnabled
    public static Live_Engagement__c getEngagement(String engagementId)
    {
        List<Live_Engagement__c> objEngagements = new List<Live_Engagement__c>([SELECT Message__c, Winner__c, Winner__r.Name, Expected_Value__c FROM Live_Engagement__c WHERE Id =: engagementId LIMIT 1]);
        if (objEngagements != null && objEngagements.size() > 0)
        {
            return objEngagements[0];
        }
        return null;
    }
    
    @AuraEnabled
    public static List<ListView> getListViews()
    {
        List<ListView> objLVs = new List<ListView>([SELECT Id, Name FROM ListView WHERE SobjectType =: 'Live_Engagement__c' ORDER BY Name]);
        return objLVs;
    }
    
    @AuraEnabled
    public static List<Live_Engagement__c> getAllEngagements(string listViewId)
    {
        ApexPages.StandardSetController ssc = new ApexPages.StandardSetController(database.getQueryLocator('select id, name from Live_Engagement__c limit 10000'));
        if (string.isNotBlank(listViewId))
        {
            ssc.setFilterId(listViewId);
        }
        
        Set<Id> allIds = new Set<Id>();
        ssc.first();
        ssc.setPageSize(1000);
        Boolean hasNext = true;
        while(hasNext){
            allIds.addAll(new Map<Id, sObject>(ssc.getRecords()).keySet());
            hasNext = ssc.getHasNext();
            ssc.next();
        }
        
        List<Live_Engagement__c> objEngagements = new List<Live_Engagement__c>([SELECT Id, Name, Active__c, Type__c, Send_Outbound_Message__c FROM Live_Engagement__c WHERE Id IN :allIds ORDER BY Session_Date__c]);
        return objEngagements;
    }
    
    @AuraEnabled
    public static List<Live_Engagement__c> toggleActivateEngagement(String engagementId, string listViewId)
    {
        List<Live_Engagement__c> objEngagements = getAllEngagements(listViewId);
        for (Live_Engagement__c currentEng : objEngagements)
        {
            if (currentEng.Id == engagementId)
            {
                currentEng.Active__c = !currentEng.Active__c;
            }
            else
            {
                currentEng.Active__c = false;
            }
        }
        UPDATE objEngagements;
        
        //Now fetch them again
        objEngagements = getAllEngagements(listViewId);
        return objEngagements;
    }
    
    @AuraEnabled
    public static Live_Engagement__c getActiveEngagement(String engagementId)
    {
        List<Live_Engagement__c> objEngagements;
        if (string.isNotBlank(engagementId))
        {
            objEngagements = new List<Live_Engagement__c>([SELECT Id, Type__c FROM Live_Engagement__c WHERE id=: engagementId LIMIT 1]);
        }
        else
        {
            objEngagements = new List<Live_Engagement__c>([SELECT Id, Type__c FROM Live_Engagement__c WHERE Active__c =: true AND Type__c != 'Notification' AND Type__c != 'Agent' LIMIT 1]);
        }
        
        if (objEngagements != null && objEngagements.size() > 0)
        {
            return objEngagements[0];
        }
        return null;
    }
    
    @AuraEnabled
    public static List<Live_Engagement_Response__c> getQuestions(String engagementId, Boolean displayALL)
    {
        //First get list of valid Engagement Results
        List<Live_Engagement_Response__c> objResponses;
        if (displayALL)
        {
            objResponses = new List<Live_Engagement_Response__c>([SELECT Id, Response__c, Contact__c, Contact_Name__c, TimeStamp__c, LastModifiedDate, Question_Response__c From Live_Engagement_Response__c WHERE Live_Engagement__c =: engagementId ORDER BY TimeStamp__c ASC]);
            
            //Now compliment it with cache
            Cache.OrgPartition pCache = Cache.Org.getPartition('local.penny');
            Set<String> allKeys = pCache.getKeys();
            for (string currentKey : allKeys)
            {
                Boolean isValid = (currentKey InstanceOf ID) ? true : false ;
                //ensure valid contact key
                if (isValid)
                {
                    List<Live_Engagement_Response__c> contactResponses = (List<Live_Engagement_Response__c>)pCache.get(currentKey);
                    if (contactResponses != null && contactResponses.size() > 0)
                    {
                        for (Live_Engagement_Response__c currResponse : contactResponses)
                        {
                            if (currResponse.Live_Engagement__c == engagementId && currResponse.isValid__c)
                            {
                                objResponses.add(currResponse);
                            }
                        }
                    }
                }
            }
            PennyResponseWrapper[] objList = new List<PennyResponseWrapper>();
            for (Live_Engagement_Response__c curR : objResponses)
            {
                objList.add(new PennyResponseWrapper(curR));
            }
            objList.sort();
            objResponses.clear();
            for (PennyResponseWrapper curR : objList)
            {
                objResponses.add(curR.resp);
            }
        }
        else
        {
            objResponses = new List<Live_Engagement_Response__c>([SELECT Id, Response__c, Contact__c, Contact_Name__c, TimeStamp__c, LastModifiedDate, Question_Response__c From Live_Engagement_Response__c WHERE Live_Engagement__c =: engagementId AND Publish_Question__c  = TRUE ORDER BY TimeStamp__c ASC]);
        }
        
        return objResponses;
    }
    
    @AuraEnabled
    public static PollResult getPollResults(String engagementId)
    {
        //First get list of valid Engagement Results
        PollResult result = new PollResult();
        List<Integer> lstdataResults = new List<Integer>();
        List<String> objLabels = getLabels(engagementId);
        system.debug(objLabels);
        if (objLabels != null && objLabels.size() > 0)
        {
            List<Live_Engagement_Response__c> objResponses = getPollVotes(engagementId);
            
            for (String currentLabel : objLabels)
            {
                Integer counter = 0;
                for (Live_Engagement_Response__c currentResponse : objResponses)
                {
                    if (currentResponse.Response__c.toLowerCase() == currentLabel.split(' ')[0].toLowerCase())
                    {
                        counter++;
                    }
                }
                lstdataResults.add(counter);
            }
        }
        result.labels = objLabels;
        result.data = lstdataResults;
        system.debug(lstdataResults);
        return result;
    }
    
    @AuraEnabled
    public static List<String> getLabels(String engagementId)
    {
        List<String> objLabels = new List<String>();
        //First see if we should be building on number or text
        Live_Engagement__c objEngagement = [SELECT Id, Message__c, isNumeric_Response__c, Min_Value__c, Max_Value__c, Type__c FROM Live_Engagement__c WHERE Id =: engagementId LIMIT 1];
        
        //If type is not poll return 
        if (objEngagement.type__c != 'Survey/Poll')
        {
            return objLabels;
        }
        if (objEngagement.Max_Value__c > objEngagement.Min_Value__c)
        {
            //Arrange by Number
            Integer counter = Integer.valueof(objEngagement.Min_Value__c);
            while (counter <= objEngagement.Max_Value__c)
            {
                boolean richLabelFound = false;
                
                //See if the outbound message has a label
                if (String.isnotBlank(objEngagement.Message__c))
                {
                    List<String> msgLines = objEngagement.Message__c.split('\\r\\n');
                    for (String lineText : msgLines)
                    {
                        if (lineText.startsWith(counter + ' '))
                        {
                            objLabels.add(lineText);
                            richLabelFound = true;
                            break;
                        }
                    }
                }
                if (!richLabelFound) objLabels.add(String.valueOf(counter));
                counter ++;
            }
        }
        
        //No more non-numeric polls
        /*else
{
List<Live_Engagement_Response__c> objResponses = getPollVotes(engagementId);
for (Live_Engagement_Response__c currentResponse : objResponses)
{
if (!objLabels.contains(currentResponse.Response__c.tolowercase()))
{
objLabels.add(currentResponse.Response__c.tolowercase());
}
}
} */
        return objLabels;
    }
    
    @AuraEnabled
    public static List<Live_Engagement_Response__c> getPollVotes(string engagementId)
    {
        List<Live_Engagement_Response__c> objResponses = new List<Live_Engagement_Response__c>([SELECT Id, Response__c From Live_Engagement_Response__c WHERE Live_Engagement__c =: engagementId AND IsValid__c = TRUE ORDER BY CreatedDate ASC]);
        
        //Now compliment it with cache
        Cache.OrgPartition pCache = Cache.Org.getPartition('local.penny');
        Set<String> allKeys = pCache.getKeys();
        for (string currentKey : allKeys)
        {
            Boolean isValid = (currentKey InstanceOf ID) ? true : false ;
            //ensure valid contact key
            if (isValid)
            {
                List<Live_Engagement_Response__c> contactResponses = (List<Live_Engagement_Response__c>)pCache.get(currentKey);
                if (contactResponses != null && contactResponses.size() > 0)
                {
                    for (Live_Engagement_Response__c currResponse : contactResponses)
                    {
                        if (currResponse.Live_Engagement__c == engagementId && currResponse.isValid__c)
                        {
                            objResponses.add(currResponse);
                        }
                    }
                }
            }
        }
        
        return objResponses;
    }
    
    @AuraEnabled
    public static string clearData()
    {
        try
        {
            
            List<Live_Engagement_Bot_Subscriber__c> objSubs = new List<Live_Engagement_Bot_Subscriber__c>([SELECT ID FROM Live_Engagement_Bot_Subscriber__c]);
            DELETE objSubs;
            
            List<Live_Engagement_Response__c> objEngRs = new List<Live_Engagement_Response__c>([SELECT ID FROM Live_Engagement_Response__c]);
            DELETE objEngRs;
            
            List<MessagingEndUser> objMUs = new List<MessagingEndUser>([SELECT ID, IsOptedOut FROM MessagingEndUser]);
            /*for (MessagingEndUser currentU : objMUs)
            {
                currentU.IsOptedOut = true;
            }
            if (objMUs.size() > 0)
            { 
                UPDATE objMUs; */
                DELETE objMUs;
            //}
            
            
            List<Contact> objContacts = new List<Contact>([SELECT ID FROM Contact]);
            DELETE objContacts;
        }
        catch (Exception e) 
        {
            // "Convert" the exception into an AuraHandledException
            throw new AuraHandledException('Error: '
                                           + e.getMessage());    
        }
        return '';
    }
    
    public class PollResult
    {
        @AuraEnabled
        List<string> labels {get;set;}
        @AuraEnabled
        List<Integer> data {get;set;}
    }
}