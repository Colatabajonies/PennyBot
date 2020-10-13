({
	doInit : function(component, event, helper) 
    {
        helper.refreshResults(component, helper, null);
        if (component.get('v.refId') == null)
        {
            var inter = window.setInterval(
                $A.getCallback(function() { 
                    helper.refreshResults(component,helper, inter);
                }), 10000
            );
        }
	}
})