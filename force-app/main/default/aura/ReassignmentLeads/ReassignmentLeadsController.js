
({
    doInit : function(component, event, helper) {
        helper.setValues(component);
    },
    
    onChange: function(component, event, helper) {

        var controlledValue = event.getSource().get("v.value");
        var fullMap = component.get("v.fullMap");
        
        if (controlledValue != '--None--') {
            var dependentFieldsList = fullMap[controlledValue];
            
            if(dependentFieldsList.length > 0) {
                component.set("v.isDisabled" , false);
                helper.setDependentValues(component, dependentFieldsList);
            } else {
                component.set("v.isDisabled" , true); 
                component.set("v.dependentValues", ['--None--']);
            }  
            
        } else {
            component.set("v.dependentValues", ['--None--']);
            component.set("v.isDisabled" , true);
        }
    }
})