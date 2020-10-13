({
	getListViews : function(component, event, helper)
    {
        component.set("v.Spinner", true);
        var action = component.get("c.getListViews");
        action.setCallback(this, function(response) {
            component.set("v.Spinner", false);
            var state = response.getState();
            if (state === "SUCCESS") {
                var storeResponse = response.getReturnValue();
                component.set("v.engListViews", storeResponse);
            }
        });
        $A.enqueueAction(action);
    },
    
    getEngagements : function(component, event, helper)
    {
        component.set("v.Spinner", true);
        var action = component.get("c.getAllEngagements");
        action.setParams({
            "listViewId" : component.get("v.selectedList")
        });
        action.setCallback(this, function(response) {
            component.set("v.Spinner", false);
            var state = response.getState();
            if (state === "SUCCESS") {
                var storeResponse = response.getReturnValue();
                component.set("v.engagements", storeResponse);
            }
        });
        $A.enqueueAction(action);
    }
})