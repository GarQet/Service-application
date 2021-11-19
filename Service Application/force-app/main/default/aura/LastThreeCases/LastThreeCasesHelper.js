({
	getUserCases : function(component) {
		let action = component.get("c.getUserCasesData");
		action.setParams({
			userId: component.get("v.currentUser.Id"),
			limitOfRecords: component.get("v.limitOfRecords")
		});
		action.setCallback(this, function(response){
			let state = response.getState();
			if (state === "SUCCESS") {
				component.set("v.ownerOfCases", response.getReturnValue());
			} else {
				console.debug(response.error[0].message);
			}
		});
		$A.enqueueAction(action);
	}
})