/* 
 * This class can be safely deleted from your org. 
 * It was only used to ensure 100% test coverage
 * for the managed package installation.
 */

@IsTest
private class InstallationTests {

    static testmethod void testWarehouseSync() {
        Test.setMock(HttpCalloutMock.class, new WarehouseCalloutServiceMock());
        Test.startTest();
        String jobId = System.schedule('WarehouseSyncSchedule',
                                       '0 0 1 * * ?', 
                                       new WarehouseSyncSchedule());   
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime
                          FROM CronTrigger
                          WHERE id = :jobId];

        System.assertEquals('0 0 1 * * ?', ct.CronExpression);
        System.assertEquals(0, ct.TimesTriggered);
        Test.stopTest();
    }    
    
}