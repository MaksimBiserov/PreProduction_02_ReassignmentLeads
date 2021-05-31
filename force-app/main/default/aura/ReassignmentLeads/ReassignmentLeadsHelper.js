
({
    setValues: function(component) {

        var action = component.get("c.getDependentMap");

        action.setCallback(this, function(response) {
            if (response.getState() == "SUCCESS") {
                var savedResponse = response.getReturnValue();

                component.set("v.fullMap", savedResponse);

                var keysList = [];
                var controlledFields = [];
                
                for (var key in savedResponse) {
                    keysList.push(key);
                }
                
                if (keysList != undefined && keysList.length > 0) {
                    controlledFields.push('--None--');
                }
                
                for (var i = 0; i < keysList.length; i++) {
                    controlledFields.push(keysList[i]);
                }

                component.set("v.controlledValues", controlledFields);
            }
        });

        $A.enqueueAction(action);
    },
    
    setDependentValues: function(component, dependentFieldsList) {

        var dependentFields = [];

        for (var i = 0; i < dependentFieldsList.length; i++) {
            dependentFields.push(dependentFieldsList[i]);
        }
        
        component.set("v.dependentValues", dependentFields);
    }
})