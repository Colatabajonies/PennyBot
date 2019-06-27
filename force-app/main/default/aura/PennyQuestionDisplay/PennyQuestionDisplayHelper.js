({
	refreshResults : function(component, helper , inter)
    {
        if (!component.isValid())
        {
            window.clearInterval(inter);
            console.log('Component no longer valid!');
            return;
        }
        
        //alert('refresh called');
        var action = component.get('c.getQuestions'); 
        // method name i.e. getEntity should be same as defined in apex class
        // params name i.e. entityType should be same as defined in getEntity method
        action.setParams({
            "engagementId" : component.get('v.recordId'),
            "displayALL" : component.get('v.displayALL')
        });
        action.setCallback(this, function(a){
            var state = a.getState(); // get the response state
            if(state == 'SUCCESS') {
                //alert(a.getReturnValue());
                //var myResults = a.getReturnValue();
                component.set('v.ChatConversation', a.getReturnValue());
            }
        });
        $A.enqueueAction(action);
    },
    
    scroll2Bottom : function(component, helper , inter2)
    {
        if (!component.isValid())
        {
            window.clearInterval(inter2);
            console.log('No more scrolling!');
            return;
        }
        
        //Else we will scroll
        var currLen = component.get('v.ChatConversation').length;
        if (currLen != component.get('v.lastScrollSize'))
        {
            component.set('v.lastScrollSize', currLen);
            component.find('scrollerB').scrollTo('bottom');
        }
    }
})