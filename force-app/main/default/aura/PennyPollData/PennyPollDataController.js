({
    afterScriptsLoaded : function(component, event, helper) 
    {
        Chart.defaults.global.defaultFontSize = 22;
        var ctx = document.getElementById('chart-' + component.get('v.recordId')).getContext('2d');
        var varMyChart = new Chart(ctx, {
            type: 'horizontalBar',
            data: {
                labels: [],
                datasets: [{
                    label: '# of votes',
                    data: [],
                    backgroundColor: [
                        'rgba(255, 99, 132, 0.5)',
                        'rgba(54, 162, 235, 0.5)',
                        'rgba(255, 206, 86, 0.5)',
                        'rgba(75, 192, 192, 0.5)',
                        'rgba(153, 102, 255, 0.5)',
                        'rgba(255, 159, 64, 0.5)',
                        'rgba(201, 203, 207, 0.5)',
                        'rgba(255, 99, 132, 0.5)',
                        'rgba(75, 192, 192, 0.5)',
                        'rgba(153, 102, 255, 0.5)',
                        'rgba(201, 159, 64, 0.5)',
                        'rgba(54, 162, 235, 0.5)',
                        'rgba(255, 206, 86, 0.5)'
                    ],
                    borderColor: [
                        'rgba(255,99,132,1)',
                        'rgba(54, 162, 235, 1)',
                        'rgba(255, 206, 86, 1)',
                        'rgba(75, 192, 192, 1)',
                        'rgba(153, 102, 255, 1)',
                        'rgba(255, 159, 64, 1)',
                        'rgba(201, 203, 207, 1)',
                        'rgba(255, 99, 132, 1)',
                        'rgba(75, 192, 192, 1)',
                        'rgba(153, 102, 255, 1)',
                        'rgba(201, 159, 64, 1)',
                        'rgba(54, 162, 235, 1)',
                        'rgba(255, 206, 86, 1)'
                    ],
                    borderWidth: 1
                }]
            },
            options: {
                scales: {
                    xAxes: [{
                        ticks: {
                            beginAtZero:true
                        }
                    }]
                }
            }
        });
        
        component.set("v.myChart", varMyChart);
        
        //Get the results
        helper.refreshResults(component,helper, null);
        var inter = window.setInterval(
            $A.getCallback(function() { 
                helper.refreshResults(component,helper, inter);
            }), 5000
        ); 
        
    },
    
    
            
})