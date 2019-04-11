({
    clickCreateItem : function(component, event, helper) {
        var isValidItem = component.find('campingItemForm').reduce(function(total,currentValue, index,arr)
                                                           {
                                                               currentValue.showHelpMessageIfInvalid();
                                                               return total && currentValue.get('v.validity').valid;
                                                           }, true);
        if(isValidItem) {
            helper.createItem(component);
        }
    },
    doInit: function(component, event, helper) {
        var action = component.get("c.getItems");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.items", response.getReturnValue());
            }
            else {
                console.log("Failed with state: " + state);
            }
        });
        $A.enqueueAction(action);
    },
    handleAddItem: function(component, event, helper) {
        var item = event.getParam("item");
        helper.updateExpense(component, item);
    }
})