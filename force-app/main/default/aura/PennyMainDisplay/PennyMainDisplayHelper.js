({
	refreshResults : function(component, helper, inter)
    {
        console.log('Checking Active Engagement...');
        if (!component.isValid())
        {
            window.clearInterval(inter);
            console.log('Component no longer valid!');
            return;
        }
        //alert('refresh called');
        var action = component.get('c.getActiveEngagement');
        action.setParams({
            "engagementId" : component.get('v.refId') 
        });
        action.setCallback(this, function(a){
            var state = a.getState(); // get the response state
            if(state == 'SUCCESS') {
                var myResults = a.getReturnValue();
                if (myResults != null)
                {
                    if (component.get('v.engagementId') != null && myResults.Id != component.get('v.engagementId') && component.get('v.engType') == myResults.Type__c)
                    {
                        if ($A.get('e.force:refreshView') != null)
                        {
                            $A.get('e.force:refreshView').fire();
                        }
                        else
                        {
                            location.reload();
                        }
                    }
                    component.set('v.engagementId', myResults.Id);
                    component.set('v.engType', myResults.Type__c);
                }
                else
                {
                    component.set('v.engagementId', null);
                    component.set('v.engType', null);
                }
            }
        });
        $A.enqueueAction(action);
        
    }
})