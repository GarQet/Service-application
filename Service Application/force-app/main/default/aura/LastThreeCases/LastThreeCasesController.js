({
    getUserCases: function(component, event, helper){
        component.set("v.loaded", true);
		helper.getUserCases(component);
    },
    hideRecords: function(component, event, helper){
        component.set("v.loaded", false);
    },  
    goToRecord : function(component, event, helper) {
        let sObjectEvent = $A.get("e.force:navigateToSObject");
        sObjectEvent.setParams({
            "recordId": event.target.parentElement.id,
            "slideDevName": 'detail'
        });
        sObjectEvent.fire();
    }
})