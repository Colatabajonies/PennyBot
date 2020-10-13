global with sharing class PennyResponseWrapper implements Comparable
{
    public Live_Engagement_Response__c resp;
    // Constructor
    public PennyResponseWrapper(Live_Engagement_Response__c r) 
    {
        resp = r;
    }
    
    // Compare opportunities based on the opportunity amount.
    global Integer compareTo(Object compareTo) {
        // Cast argument to OpportunityWrapper
        PennyResponseWrapper compareToOppy = (PennyResponseWrapper)compareTo;
        
        // The return value of 0 indicates that both elements are equal.
        Integer returnValue = 0;
        if (resp.TimeStamp__c > compareToOppy.resp.TimeStamp__c) {
            // Set return value to a positive value.
            returnValue = 1;
        } else if (resp.TimeStamp__c < compareToOppy.resp.TimeStamp__c) {
            // Set return value to a negative value.
            returnValue = -1;
        }
        
        return returnValue;       
    }
}