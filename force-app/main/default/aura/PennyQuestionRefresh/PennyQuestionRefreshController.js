({
    handleClick : function (cmp, event, helper) 
    {
        var action = cmp.get('c.UpsertCache'); 
        action.setCallback(this, function(a)
        {
            var state = a.getState(); // get the response state
            if(state == 'SUCCESS') 
            {
                $A.get('e.force:refreshView').fire();
            }
        });
        $A.enqueueAction(action);
    }
})