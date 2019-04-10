@isTest
public class MaintenanceRequestHelperTest {

    public static final Integer BULK_QANT = 300;

    @isTest 
    static void testPositive(){
        List<Vehicle__c> listOfVehicles = new List<Vehicle__c>();
        List<Case> listOfMaintenanceRequests = new List<Case>();
        List<Work_Part__c> listOfWorkParts = new List<Work_Part__c>();
        List<Product2> listOfEquipments = new List<Product2>();
        
        // Creo 300 vehiculos
        for ( Integer i = 0 ; i < BULK_QANT ; i ++ ) {
            Vehicle__c newVehicle = new Vehicle__c();
            newVehicle.Name = 'Vehicle ' + i;
            listOfVehicles.add( newVehicle );
        }
        
        insert listOfVehicles;
        
        // Creo 50 equipment
        for ( Integer i = 0 ; i < 50 ; i ++ ) {
            Product2 newEquipment = new Product2();
            newEquipment.Name = 'Equipment ' + i;
            newEquipment.IsActive = true;
            newEquipment.Replacement_Part__c = true;
            newEquipment.Maintenance_Cycle__c = 10;
            newEquipment.Lifespan_Months__c = 10;
            listOfEquipments.add( newEquipment );
        }
        
        insert listOfEquipments;
        
        // Create Maintenance Requests for every Vehicle
        Integer j = 0;
        for ( Integer i = 0 ; i < listOfVehicles.size() ; i ++ ) {
            Vehicle__c vehicle = listOfVehicles.get(i);
            Case newMaintenance = new Case();
            newMaintenance.Type = 'Repair';
            newMaintenance.Status = 'New';
            newMaintenance.Origin = 'Phone';
            newMaintenance.Vehicle__c = vehicle.Id;
            newMaintenance.Equipment__c = listOfEquipments.get(j).Id;
            listOfMaintenanceRequests.add( newMaintenance );

            if( j == 49 ){
                j = 0;
            } else {
                j++;
            }
        }
        
        insert listOfMaintenanceRequests;

        // Create a work part for every maintenance request
        for ( Case maintenaceRequest : listOfMaintenanceRequests ) {
            Work_Part__c newWorkPart = new Work_Part__c();
            newWorkPart.Maintenance_Request__c = maintenaceRequest.Id;
            newWorkPart.Equipment__c = maintenaceRequest.Equipment__c;
            newWorkPart.Quantity__c = 10;
            listOfWorkParts.add( newWorkPart );
        }
        
        insert listOfWorkParts;

        Test.startTest();
            for(Case c : listOfMaintenanceRequests){
                c.Status = 'Closed';
            }
            update listOfMaintenanceRequests;
        Test.StopTest();

        //For each one create one Case with Type Routine Maintenance
        List<Case> newMaintenances = [SELECT Date_Reported__c, Equipment__c, Vehicle__c, Date_Due__c, Subject  FROM Case Where Type = 'Routine Maintenance'];
        System.assertEquals( newMaintenances.size(), listOfMaintenanceRequests.size() );

        for ( Case newMaintenance : newMaintenances) {
            System.assertEquals( newMaintenance.Date_Reported__c, System.today() );
            System.assertNotEquals( newMaintenance.Equipment__c , null);
            System.assertNotEquals( newMaintenance.Subject , null);
            System.assertEquals( newMaintenance.Date_Due__c, System.today().addMonths( 10 ));
        }
    }

    @isTest 
    static void testMultiEquipment(){
        List<Vehicle__c> listOfVehicles = new List<Vehicle__c>();
        List<Case> listOfMaintenanceRequests = new List<Case>();
        List<Work_Part__c> listOfWorkParts = new List<Work_Part__c>();
        List<Product2> listOfEquipments = new List<Product2>();
        
        // Creo 300 vehiculos
        for ( Integer i = 0 ; i < 10 ; i ++ ) {
            Vehicle__c newVehicle = new Vehicle__c();
            newVehicle.Name = 'Vehicle ' + i;
            listOfVehicles.add( newVehicle );
        }
        
        insert listOfVehicles;
        
        // Creo 50 equipment
        for ( Integer i = 0 ; i < 50 ; i ++ ) {
            Product2 newEquipment = new Product2();
            newEquipment.Name = 'Equipment ' + i;
            newEquipment.IsActive = true;
            newEquipment.Replacement_Part__c = true;
            newEquipment.Maintenance_Cycle__c = 10;
            newEquipment.Lifespan_Months__c = 10;
            listOfEquipments.add( newEquipment );
        }
        
        insert listOfEquipments;
        
        // Create Maintenance Requests for every Vehicle
        for ( Integer i = 0 ; i < listOfVehicles.size() ; i ++ ) {
            Vehicle__c vehicle = listOfVehicles.get(i);
            Case newMaintenance = new Case();
            newMaintenance.Type = 'Repair';
            newMaintenance.Status = 'New';
            newMaintenance.Origin = 'Phone';
            newMaintenance.Vehicle__c = vehicle.Id;
            newMaintenance.Equipment__c = listOfEquipments.get(i).Id;
            listOfMaintenanceRequests.add( newMaintenance );
        }
        insert listOfMaintenanceRequests;

        Integer count = 1;

        while (count < 3) {
            // Create a work part for every maintenance request
            for ( Case maintenaceRequest : listOfMaintenanceRequests ) {
                Work_Part__c newWorkPart = new Work_Part__c();
                newWorkPart.Maintenance_Request__c = maintenaceRequest.Id;
                newWorkPart.Equipment__c = maintenaceRequest.Equipment__c;
                newWorkPart.Quantity__c = 10;
                listOfWorkParts.add( newWorkPart );
            }

            count++;
        }
        
        insert listOfWorkParts;

        Test.startTest();
            for(Case c : listOfMaintenanceRequests){
                c.Status = 'Closed';
            }
            update listOfMaintenanceRequests;
        Test.StopTest();

        //For each one create one Case with Type Routine Maintenance
        List<Case> newMaintenances = [SELECT Date_Reported__c, Equipment__c, Vehicle__c, Date_Due__c, Subject  FROM Case Where Type = 'Routine Maintenance'];
        System.assertEquals( newMaintenances.size(), listOfMaintenanceRequests.size() );

        for ( Case newMaintenance : newMaintenances) {
            System.assertEquals( newMaintenance.Date_Reported__c, System.today() );
            System.assertNotEquals( newMaintenance.Equipment__c , null);
            System.assertNotEquals( newMaintenance.Subject , null);
            System.assertEquals( newMaintenance.Date_Due__c, System.today().addMonths( 10 ));
        }
        
    }
}