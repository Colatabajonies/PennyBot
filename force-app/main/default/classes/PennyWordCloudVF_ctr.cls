public with sharing class PennyWordCloudVF_ctr 
{
    Public String outputWords{get;set;}
    Public String leID {get;set;}
    Public List<wc> objOutputWords{get;set;}
    
    public PennyWordCloudVF_ctr()
    {
        outputWords = '[]';
        leID = ApexPages.currentPage().getParameters().get('Id');
        if (String.isNotBlank(leID))
        {
            refreshData();
        }        
    }
    
    public void refreshData()
    {
        objOutputWords = new List<wc>();
        if (String.isNotBlank(leID))
        {
            outputWords = '[';
            List<Live_Engagement_Response__c> objResps = new List<Live_Engagement_Response__c>([SELECT Id, Response__c From Live_Engagement_Response__c WHERE Live_Engagement__c =: leID]);
            for (Live_Engagement_Response__c curResp : objResps)
            {
                outputWords += '"' + curResp.Response__c + '",';
                Boolean found = false;
                for (wc currentWord : objOutputWords)
                {
                    if (currentWord.text.toLowerCase() == curResp.Response__c.toLowerCase())
                    {
                        currentWord.frequency += 1;
                        found = true;
                        break;
                    }
                }
                if (!found)
                {
                    wc newWord = new wc();
                    newWord.text = curResp.Response__c;
                    newWord.frequency = 1;
                    objOutputWords.add(newWord);
                }
            }
            
            //Now compliment it with cache
            Cache.OrgPartition pCache;
            try
            {
                pCache = Cache.Org.getPartition('local.penny');
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
                                if (currResponse.Live_Engagement__c == leID)
                                {
                                    outputWords += '"' + currResponse.Response__c + '",';
                                    Boolean found = false;
                                    for (wc currentWord : objOutputWords)
                                    {
                                        if (currentWord.text.toLowerCase() == currResponse.Response__c.toLowerCase())
                                        {
                                            currentWord.frequency += 1;
                                            found = true;
                                            break;
                                        }
                                    }
                                    if (!found)
                                    {
                                        wc newWord = new wc();
                                        newWord.text = currResponse.Response__c;
                                        newWord.frequency = 1;
                                        objOutputWords.add(newWord);
                                    }
                                }
                            }
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                //No cache found
                system.debug('Not using cache. Please configure org cache partition local.penny if using for events with 30+ participants...');
            }
            
            
            
            outputWords = '[';
            integer myscale = this.getScale(objOutputWords);
            for (wc cw : objOutputWords)
            {
                outputWords += '{"text": "' + cw.text + '", "frequency": "' + String.valueOf(cw.frequency * myscale) + '"},';
            }
            
            outputWords = outputWords.removeEnd(',') + ']';
        }
    }
    
    public integer getScale(List<wc> words)
    {
        integer maxfreq = 1;
        for (wc cw : words)
        {
            maxfreq = Math.max(cw.frequency, maxfreq);
        }
        
        return (Integer)Math.ceil(Decimal.valueOf(20).divide(maxfreq, /*digits*/ 1));
    }
    
    
    public class wc
    {
        public string text;
        public integer frequency;
    }
}