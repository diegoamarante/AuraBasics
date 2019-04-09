public class MaintenanceRequestHelper {

    public static void updateWorkOrders(List<Case> cases){
        //Get the Case Id to get the Work Part
        Set<Id> caseId = new Set<Id>();
        List<Case> casesToClone = new List<Case>();
        for (Case req : cases) {
            if( (req.Type == 'Repair'|| req.Type == 'Routine Maintenance') && req.Status == 'Closed' ){
                caseId.add(req.Id);
                casesToClone.add(req);
            }
        }

        Map<Id, List<Work_Part__c>> workPartByCaseMap = new Map<Id, List<Work_Part__c>>();
        for(Work_Part__c wp : [Select Id, Maintenance_Request__c, Equipment__r.Lifespan_Months__c FROM Work_Part__c WHERE Maintenance_Request__c In: caseId Order By Equipment__r.Lifespan_Months__c ASC]){
            if( workPartByCaseMap.containsKey(wp.Maintenance_Request__c) ){
                workPartByCaseMap.get(wp.Maintenance_Request__c).add(wp);
            } else {
                workPartByCaseMap.put(wp.Maintenance_Request__c, new List<Work_Part__c>{wp});
            }
        }

        List<Case> newRequests = new List<Case>();
        for (Case req : casesToClone) {
            if( (req.Type == 'Repair'|| req.Type == 'Routine Maintenance') && req.Status == 'Closed' ){
                Case newRequest = req.clone(false);
                newRequest.Type = 'Routine Maintenance';
                newRequest.Status = 'New';

                if( String.isBlank(newRequest.Subject) ){
                    newRequest.Subject = 'New self generated routine';
                }
                
                // The Report Date field reflects the day the request was created
                newRequest.Date_Reported__c = Date.newInstance(req.CreatedDate.year(), req.CreatedDate.month(), req.CreatedDate.day());

                //Another aspect about parts is they all have different lifespans. Therefore, you need to calculate and set the next due date using the maintenance cycle defined on the related work part records. If multiple work parts are used in the maintenance request, choose the shortest maintenance cycle to define the service date.
                if( workPartByCaseMap.containsKey(req.Id) ){
                    // && workPartByCaseMap.get(req.Id).size() > 0
                    newRequest.Date_Due__c = System.today().addMonths( (Integer)workPartByCaseMap.get(req.Id).get(0).Equipment__r.Lifespan_Months__c );
                }
                newRequests.add(newRequest);
            }
        }

        if( !newRequests.isEmpty() ){
            insert newRequests;
        }
    }
}