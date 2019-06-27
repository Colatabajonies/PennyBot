({  
    refreshResults : function(component, helper, inter)
    {
        if (!component.isValid())
        {
            window.clearInterval(inter);
            console.log('Component no longer valid!');
            return;
        }
        //alert('refresh called');
        var action = component.get('c.getPollResults'); 
        // method name i.e. getEntity should be same as defined in apex class
        // params name i.e. entityType should be same as defined in getEntity method
        action.setParams({
            "engagementId" : component.get('v.recordId') 
        });
        action.setCallback(this, function(a){
            var state = a.getState(); // get the response state
            if(state == 'SUCCESS') {
                var myResults = a.getReturnValue();
                //alert(myResults.labels);
                this.addData(component, myResults.labels, myResults.data);
                //component.set('v.sObjList', a.getReturnValue());
            }
        });
        $A.enqueueAction(action);
        
        //this.addData(component, [Math.floor(Math.random() * 21), Math.floor(Math.random() * 21), Math.floor(Math.random() * 21), Math.floor(Math.random() * 21), Math.floor(Math.random() * 21), Math.floor(Math.random() * 21), Math.floor(Math.random() * 21)]);
    },
    
    addData : function(component, labels, data) 
    {
        var varMyChart = component.get("v.myChart");
        varMyChart.data.labels = labels;
        varMyChart.data.datasets.forEach((dataset) => {
            //alert(data);
            dataset.data = data;
        });
        varMyChart.update();
    },
})