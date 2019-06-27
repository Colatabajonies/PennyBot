public class PennyHelper 
{
    Public static string noEngagementText = 'Hi there, I\'m not able to process your response at this time. Stay tuned, I\'ll be looking for your feedback soon.';
    Public static string questionRText = 'Thanks for your question. We\'ll review it and let you know when we find an answer.';
    Public static string ffWrong = 'I\'m sorry. That does not appear to be the right answer';
    Public static string ffRight = 'Congratulations, You were the first one to get the right answer. Stay tuned to be announced as the winner!';
    Public static string ffOver = 'Thanks for your response. Unfortunately, someone has already responded with the correct answer. Try to be a bit faster next time!';
    Public static string wordCloudText = 'Got it. We\'ll add your response to the Word Cloud.';
    Public static string transferText = 'Give me a second, and I\'ll be right with you...';
    Public static string errorText = 'Oops, looks like there\'s a problem. Make sure you reply with a valid response.';
    
    @AuraEnabled
    public static void UpsertCache()
    {
        Cache.OrgPartition pCache = Cache.Org.getPartition('local.penny');
        List<Live_Engagement_Response__c> newResponses = New List<Live_Engagement_Response__c>();
        
        //Loop through all the bot subscribers
        //List<Live_Engagement_Bot_Subscriber__c> objSubScribers = new List<Live_Engagement_Bot_Subscriber__c>([Select ID, Contact__c, Bot_Developer_Name__c FROM Live_Engagement_Bot_Subscriber__c]);
        
        Set<String> allKeys = pCache.getKeys();
        for (string currentKey : allKeys)
        {
            Boolean isValid = (currentKey InstanceOf ID) ? true : false ;
            //ensure valid contact key
            if (isValid)
            {
                List<Live_Engagement_Response__c> newResponse = (List<Live_Engagement_Response__c>)pCache.get(currentKey);
                if(newResponse != null && newResponse.size() > 0)
                {
                    newResponses.addall(newResponse);
                    pCache.remove(currentKey);
                }
            } 
        }
        
        if (newResponses.size() > 0)
        {
            UPSERT newResponses;
        }
    }
    
    public static string GetChoiceFromPoll(string selection, string message)
    {
        string retVal = selection;
        
        for (string currentLine : message.split('\\r\\n'))
        {
            if (currentLine.startsWith(selection + ' '))
            {
                return currentLine;
            }
        }
        return retVal;
    }
    
    public static string ProcessEngagementResponse(List<Live_Engagement__c> objEngagements, Live_Engagement__c currEngagement, Cache.OrgPartition pCache, Contact objContact, String strUtterance, Integer MaxLen, String QRecordTypeID)
    {
        string resultText = errorText;
        
        //get the cache
        List<Live_Engagement_Response__c> objResponses = (List<Live_Engagement_Response__c>)pCache.get(objContact.Id);
        if (objResponses == null)
        {
            objResponses = new List<Live_Engagement_Response__c>();
        }
        
        if (currEngagement.Type__c == 'Agent')
        {
            Live_Engagement_Response__c newResponse = new Live_Engagement_Response__c();
            newResponse.Live_Engagement__c = currEngagement.Id;
            newResponse.Contact__c = objContact.Id;
            newResponse.Response__c = (strUtterance.length() <= maxLen ? strUtterance : strUtterance.substring(0, maxLen));
            newResponse.isValid__c = true;
            newResponse.RecordTypeId = QRecordTypeID; //Schema.SObjectType.Live_Engagement_Response__c.getRecordTypeInfosByName().get('Question').getRecordTypeId();
            newResponse.TimeStamp__c = Datetime.now();
            newResponse.Contact_Name__c = (String.isNotBlank(objContact.Name) ? objContact.Name : objContact.FirstName + ' ' + objContact.LastName);
            objResponses.add(newResponse);
            pCache.put(objContact.Id, objResponses);
            resultText = transferText;
        }
        else if (currEngagement.Type__c == 'Fastest Finger')
        {
            if (currEngagement.Winner__c != null)
            {
                resultText = ffOver;
            }
            else if (currEngagement.isNumeric_Response__c)
            {
                Decimal lngInput = Decimal.valueOf(strUtterance);
                if (lngInput < currEngagement.Min_Value__c || lngInput > currEngagement.Max_Value__c)
                {
                    resultText = ffWrong;
                }
                else
                {
                    //they WON!!!
                    currEngagement.Winner__c = objContact.Id;
                    pCache.put('EngagementIds', objEngagements);
                    UPDATE currEngagement;
                    resultText = ffRight;
                }
            }
            else
            {
                if (currEngagement.Expected_Value__c.tolowercase().trim() == strUtterance.toLowerCase().trim())
                {
                    //they WON!!!
                    currEngagement.Winner__c = objContact.Id;
                    pCache.put('EngagementIds', objEngagements);
                    UPDATE currEngagement;
                    resultText = ffRight;
                }
                else
                {
                    resultText = ffWrong;
                }
            }
        }
        else if (currEngagement.Type__c == 'Word Cloud')
        {
            Live_Engagement_Response__c newResponse = new Live_Engagement_Response__c();
            newResponse.Live_Engagement__c = currEngagement.Id;
            newResponse.Contact__c = objContact.Id;
            newResponse.Response__c = (strUtterance.length() <= maxLen ? strUtterance : strUtterance.substring(0, maxLen));
            newResponse.isValid__c = true;
            newResponse.TimeStamp__c = Datetime.now();
            newResponse.Contact_Name__c = (String.isNotBlank(objContact.Name) ? objContact.Name : objContact.FirstName + ' ' + objContact.LastName);
            objResponses.add(newResponse);
            pCache.put(objContact.Id, objResponses);
            resultText = wordCloudText;
        }
        else if (currEngagement.Type__c == 'Questions')
        {
            Live_Engagement_Response__c newResponse = new Live_Engagement_Response__c();
            newResponse.Live_Engagement__c = currEngagement.Id;
            newResponse.Contact__c = objContact.Id;
            newResponse.Response__c = (strUtterance.length() <= maxLen ? strUtterance : strUtterance.substring(0, maxLen));
            newResponse.isValid__c = true;
            newResponse.RecordTypeId = QRecordTypeID; //Schema.SObjectType.Live_Engagement_Response__c.getRecordTypeInfosByName().get('Question').getRecordTypeId();
            newResponse.TimeStamp__c = Datetime.now();
            newResponse.Contact_Name__c = (String.isNotBlank(objContact.Name) ? objContact.Name : objContact.FirstName + ' ' + objContact.LastName);
            
            objResponses.add(newResponse);
            pCache.put(objContact.Id, objResponses);
            resultText = questionRText;
        }
        else
        {
            //We are looking at poll data
            //First see if this result will even be valid...
            
            //We are processing a numeric response
            Long lngInput = Long.valueOf(strUtterance);
            
            if (lngInput < currEngagement.Min_Value__c || lngInput > currEngagement.Max_Value__c)
            {
                //Invalid Input
                if (currEngagement != null && String.isNotBlank(currEngagement.Message__c))
                {
                    resultText += '\r\n\r\n' + currEngagement.Message__c.replace('{firstname}', (objContact.firstName != null ? objContact.firstName : objContact.name));
                }
                return resultText;
            }
            
            //Get previous Responses
            Live_Engagement_Response__c newResponse = new Live_Engagement_Response__c();
            newResponse.Live_Engagement__c = currEngagement.Id;
            newResponse.Contact__c = objContact.Id;
            newResponse.Response__c = (strUtterance.length() <= maxLen ? strUtterance : strUtterance.substring(0, maxLen));
            newResponse.isValid__c = true;
            
            //Get friendly response value
            String strFriendlyResponse = PennyHelper.GetChoiceFromPoll(newResponse.Response__c, currEngagement.Message__c);
            
            if (objResponses == null || objResponses.size() == 0)
            {
                //New one
                objResponses.add(newResponse);
                pCache.put(objContact.Id, objResponses);
                resultText = 'Thanks. I set your response as "' + strFriendlyResponse + '"\r\nSession: ' +  currEngagement.Name;
            }
            else
            {
                //Iterate through the responses and update
                Boolean isFound = false;
                for (Live_Engagement_Response__c currentResponse : objResponses)
                {
                    if (currentResponse.Live_Engagement__c == newResponse.Live_Engagement__c)
                    {
                        //Update this one
                        currentResponse.Response__c = newResponse.Response__c;
                        isFound = true;
                        break;
                    }
                }
                if (!isFound)
                {
                    objResponses.add(newResponse);
                }
                pCache.put(objContact.Id, objResponses);
                if (!isFound)
                {
                    resultText = 'Thanks. I set your response as "' + strFriendlyResponse + '"\r\nSession: ' +  currEngagement.Name;
                }
                else
                {
                    resultText = 'Thanks. I updated your response to "' + strFriendlyResponse + '"\r\nSession: ' +  currEngagement.Name;
                }
            }
        }
        
        return resultText;
    }
    
    Public static List<Live_Engagement__c> GetEngagementstoProcess(List<Live_Engagement__c> objMultiEngagements, string strBotName, string strUtterance)
    {
        List<Live_Engagement__c> objEngagements;
        if (objMultiEngagements != null && objMultiEngagements.size() > 0)
        {
            objEngagements = new List<Live_Engagement__c>();
            Boolean engFound = false;
            //see if the utterance is numeric (for poll)
            Boolean onlyPolls = strUtterance.remove('.').isNumeric();
            
            //First try to match the input with an engagement
            for (Live_Engagement__c currentEngagement : objMultiEngagements)
            {
                if (currentEngagement.Bot_Developer_Name__c == strBotName)
                {
                    engFound = true;
                    if ((onlyPolls && (currentEngagement.isNumeric_Response__c || currentEngagement.Type__c == 'Survey/Poll'))
                        ||
                        (!onlyPolls && currentEngagement.Type__c != 'Survey/Poll' && !currentEngagement.isNumeric_Response__c)
                       )
                    {
                        objEngagements.add(currentEngagement);
                    }
                }
            }
            
            //If we found engagements but not any matching the engagement type... just add them
            if (objEngagements.size() == 0 && engFound)
            {
                for (Live_Engagement__c currentEngagement : objMultiEngagements)
                {
                    if (currentEngagement.Bot_Developer_Name__c == strBotName)
                    {
                        objEngagements.add(currentEngagement);
                    }
                }
            }
        }
        return objEngagements;
    }
    
    public static void AutoActivate()
    {
        //First get all AutoActivate candidates
        List<Live_Engagement__c> objEngagements = new List<Live_Engagement__c>([SELECT ID, AutoActivate__c, Session_Date__c, Active__c FROM Live_Engagement__c WHERE Active__c =: false AND AutoActivate__c =: true AND Send_Outbound_Message__c =: true AND Session_Date__c <=: Datetime.now() AND Session_Date__c >: Datetime.now().addMinutes(-15)]);
        
        if (objEngagements.size() > 0)
        {
            for (Live_Engagement__c currEng : objEngagements)
            {
                currEng.AutoActivate__c = false;
            }
            UPDATE objEngagements;
            
            Live_Engagement__c objEng = objEngagements[0];
            objEng.Active__c = true;
            UPDATE objEng;
        }
    }
}