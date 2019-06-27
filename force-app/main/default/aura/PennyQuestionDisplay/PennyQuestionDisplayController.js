({
	doInit : function(component, event, helper) 
    {
        
		//Get the results
		//alert('init');
        helper.refreshResults(component,helper, null);
        var inter = window.setInterval(
            $A.getCallback(function() { 
                helper.refreshResults(component,helper, inter);
            }), 15000
        );
        
        if (component.get('v.autoScroll'))
        {
            var inter2 = window.setInterval(
                $A.getCallback(function() { 
                    helper.scroll2Bottom(component,helper, inter2);
                }), 6000
            );
        }
    }
})