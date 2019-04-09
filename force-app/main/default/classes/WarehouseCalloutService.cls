public with sharing class WarehouseCalloutService {

    private static final String WAREHOUSE_URL = 'https://th-superbadge-apex.herokuapp.com/equipment';
    
    // complete this method to make the callout (using @future) to the
    // REST endpoint and update equipment on hand.
    @future(callout=true)
    public static void runWarehouseEquipmentSync(){

        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint(WAREHOUSE_URL);
        request.setMethod('GET');
        HttpResponse response = http.send(request);
        
        // If the request is successful, parse the JSON response.
        if (response.getStatusCode() == 200) {
            // Deserialize the JSON string into collections of primitive data types.
            List<Equipment> equipments = (List<Equipment>)Json.deserialize(response.getBody(), List<Equipment>.class);
            System.debug('equipments '+equipments);
            
            List<Product2> newEquipment = new List<Product2>();
            for(Equipment e : equipments){
                Product2 equipment = new Product2();
                equipment.Replacement_Part__c = e.replacement;
                equipment.Current_Inventory__c = e.quantity;
                equipment.Name = e.name;
                equipment.Maintenance_Cycle__c = e.maintenanceperiod;
                equipment.Lifespan_Months__c = e.lifespan;
                equipment.Cost__c = e.cost;
                equipment.Warehouse_SKU__c = e.sku;
                equipment.id = e.equipmentId;
                System.debug('[Equipment]:'+equipment);
                newEquipment.add(equipment);
            }
            System.debug('List:'+newEquipment);
            System.debug('Size:'+newEquipment.size());
            upsert newEquipment;
        }
    }


    private class Equipment {
        public String equipmentId;
        public Boolean replacement;
        public Integer quantity;
        public String name;
        public Integer maintenanceperiod;
        public Integer lifespan;
        public Integer cost;
        public String sku;
    }
}