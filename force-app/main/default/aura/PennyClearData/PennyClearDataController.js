({
	handleClick : function(component, event, helper) 
    {
        component.set("v.Spinner", true);
        var action = component.get('c.clearData'); 
        action.setCallback(this, function(a)
        {
            //alert(a.getError()[0].message);
            component.set("v.Spinner", false);
            var state = a.getState(); // get the response state
            if(state == 'SUCCESS') {
                var retVal = a.getReturnValue();
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Data Cleared",
                    "type": "success",
                    "message": "All Penny data has been removed from the system."
                });
                toastEvent.fire();
            }
            
            else if (state === "ERROR" && a.getError() && a.getError()[0] && a.getError()[0].message) {
                var errors = a.getError();
                var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Error",
                        "type": "error",
                        "message":  "\"" + errors[0].message + "\""
                    });
                    toastEvent.fire();
            }
            
            else
            {
                var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Error",
                        "type": "error",
                        "message": "Error clearing Penny data."
                    });
                    toastEvent.fire();
            }
        });
        $A.enqueueAction(action);
        
	}
})