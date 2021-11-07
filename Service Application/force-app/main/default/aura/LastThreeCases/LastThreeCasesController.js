({
    getUserCases: function(component,event,helper){
        component.set("v.loaded", !component.get("v.loaded"));
        let load = component.get("v.currentUser.Id");
        if(load != null) {
            let action = component.get("c.getUserCasesData");
            action.setParams({
                user: component.get("v.currentUser"),
                limitOfRecords: component.get("v.limitOfRecords")
            });
            action.setCallback(this, function(response){
                console.debug(response);
                let state = response.getState();
                if (state === "SUCCESS") {
                    component.set("v.ownerOfCases", response.getReturnValue());
                } else {
                    console.debug(response.error[0].message);
                }
            });
            $A.enqueueAction(action);
        }
    },
    hideRecords: function(component,event,helper){
        component.set("v.loaded", !component.get("v.loaded"));
    },  
    gotoRecord : function(component,event,helper) {
        let id;
        let element = event.srcElement;
        while(element.parentNode) {
            if(element.id != "") {
                id = element.id;
                break;
            }
            element = element.parentNode;
        }
        if(id == null) { return; }
        var sObjectEvent = $A.get("e.force:navigateToSObject");
        sObjectEvent.setParams({
            "recordId": id,
            "slideDevName": 'detail'
        });
        sObjectEvent.fire();
    }
})