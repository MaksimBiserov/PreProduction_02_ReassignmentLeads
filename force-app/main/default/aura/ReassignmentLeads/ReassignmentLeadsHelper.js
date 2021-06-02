
({
    setValues : function(component) {

        var adressAction = component.get("c.getDependentMap");
        var ownerAction = component.get("c.getOwnerNames");

        adressAction.setCallback(this, function(response) {
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

        ownerAction.setCallback(this, function(response) {

            if (response.getState() == "SUCCESS") {
                var owners = [];
                var values = response.getReturnValue();

                owners.push('--None--');

                for (var i = 0; i < values.length; i++) {
                    owners.push(values[i]);
                }

                component.set("v.ownerValues", owners);
            }
        });

        $A.enqueueAction(adressAction);
        $A.enqueueAction(ownerAction);
    },
    
    setDependentValues: function(component, dependentFieldsList) {

        var dependentFields = [];

        for (var i = 0; i < dependentFieldsList.length; i++) {
            dependentFields.push(dependentFieldsList[i]);
        }
        
        component.set("v.dependentValues", dependentFields);
    }
})