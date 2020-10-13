({
	doInit : function(component, event, helper)
    {
        helper.getListViews(component, event, helper); 
    },
    
    toggleActivate: function(component, event, helper) 
    {
        component.set("v.Spinner", true);
        var idx = event.currentTarget.dataset.engid;
        //alert(idx); //here is your ID
        
        var action = component.get("c.toggleActivateEngagement");
        action.setParams({
            "engagementId" : idx,
            "listViewId" : component.get("v.selectedList")
        });
        action.setCallback(this, function(response) {
            component.set("v.Spinner", false);
            var state = response.getState();
            if (state === "SUCCESS") {
                var storeResponse = response.getReturnValue();
                component.set("v.engagements", storeResponse);
            }
            else
            {
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Error",
                    "type": "error",
                    "message": "Error toggling Engagement activation."
                });
                toastEvent.fire();
            }
        });
        $A.enqueueAction(action);
    },
    
    handleListChange : function(component, event, helper)
    {
        //alert(event.getParam('value'));
        helper.getEngagements(component, event, helper);
    }
})