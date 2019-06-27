({
    doInit : function(component, event, helper) 
    {
        helper.refreshResults(component,helper, null);
        var inter = window.setInterval(
            $A.getCallback(function() { 
                helper.refreshResults(component,helper, inter);
            }), 5000
        ); 
    }
})