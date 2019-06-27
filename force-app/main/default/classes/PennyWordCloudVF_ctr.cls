public class PennyWordCloudVF_ctr 
{
    Public String outputWords{get;set;}
    Public String leID {get;set;}
    
    public PennyWordCloudVF_ctr()
    {
        outputWords = '';
        leID = ApexPages.currentPage().getParameters().get('Id');
        if (String.isNotBlank(leID))
        {
            refreshData();
        }
        
    }
    
    public void refreshData()
    {
        if (String.isNotBlank(leID))
        {
            outputWords = '';
            List<Live_Engagement_Response__c> objResps = new List<Live_Engagement_Response__c>([SELECT Id, Response__c From Live_Engagement_Response__c WHERE Live_Engagement__c =: leID]);
            for (Live_Engagement_Response__c curResp : objResps)
            {
                outputWords += curResp.Response__c + '|';
            }
            
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
                            if (currResponse.Live_Engagement__c == leID)
                            {
                                outputWords += currResponse.Response__c + '|';
                            }
                        }
                    }
                }
            }
            
            outputWords = outputWords.removeEnd('|');
        }
    }
}