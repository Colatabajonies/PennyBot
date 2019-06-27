public class PennyChatVFController 
{
    Private List<string> displayedIDs {get;set;}
    Public String outputChat{get;set;}
    
    public PennyChatVFController()
    {
        displayedIDs = new list<string>();
        //refreshData();
    }
    
    public void refreshData()
    {
        outputChat = '';
        List<Live_Engagement_Response__c> objResponses = new List<Live_Engagement_Response__c>([SELECT ID, Contact__r.Name, Response__c FROM Live_Engagement_Response__c WHERE isValid__c = true AND Type__c =:'Questions' ORDER BY CreatedDate DESC LIMIT 10]);
        if (objResponses.Size() > 0)
        {
            for (integer i = objResponses.Size()-1; i >=0 ; i--)
            {
                if (!displayedIDs.contains(String.valueof(objResponses[i].id)))
                {
                    displayedIDs.add(String.valueof(objResponses[i].id));
                    //outputChat =  String.valueof(displayedIDs[0]) + '|' + String.valueof(displayedIDs.size()) + ' - ' + String.valueof(objResponses[i].id);
                    outputChat += objResponses[i].Contact__r.Name.remove('|') + '|' + objResponses[i].Response__c.remove('|') + '#|#';
                    //return;
                }
            }
        }
        
    }
}