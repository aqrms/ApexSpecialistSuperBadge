/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an org are executed whenever Apex code is deployed
 * to a production org to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production org. In addition, all triggers must have some code coverage.
 *
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the org size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class MaintenanceRequestTest {
    @testSetup
    static void setupTestData() {
        Vehicle__c vehicle = new Vehicle__c(Name = 'Test Vehicle');
        insert vehicle;

        Product2 equipment = new Product2(
            Name = 'Test Equipment',
            Maintenance_Cycle__c = 10,
            Replacement_Part__c = true
        );
        insert equipment;
    }

    @isTest
    static void testBulkMaintenanceRequestCreation() {
        Vehicle__c vehicle = [SELECT Id FROM Vehicle__c LIMIT 1];
        Product2 equipment = [SELECT Id FROM Product2 LIMIT 1];

        List<Case> maintenanceRequests = new List<Case>();
        List<Equipment_Maintenance_Item__c> maintenanceItems = new List<Equipment_Maintenance_Item__c>();

        for (Integer i = 0; i < 300; i++) {
            Case request = new Case(
                Type = 'Repair',
                Status = 'New',
                Origin = 'Phone',
                Subject = 'Repair needed ' + i,
                Vehicle__c = vehicle.Id
            );
            maintenanceRequests.add(request);
        }
        insert maintenanceRequests;

        for (Case request : maintenanceRequests) {
            Equipment_Maintenance_Item__c item = new Equipment_Maintenance_Item__c(
                Equipment__c = equipment.Id,
                Maintenance_Request__c = request.Id
            );
            maintenanceItems.add(item);
        }
        insert maintenanceItems;

        Test.startTest();
        for (Case request : maintenanceRequests) {
            request.Status = 'Closed';
        }
        update maintenanceRequests;
        Test.stopTest();

        List<Case> newRequests = [SELECT Id FROM Case WHERE ParentId IN :maintenanceRequests];

        System.assertEquals(300, newRequests.size(), '300 new maintenance requests should have been created');

        List<Equipment_Maintenance_Item__c> newItems = [
            SELECT Id
            FROM Equipment_Maintenance_Item__c
            WHERE Maintenance_Request__c IN :newRequests
        ];
        System.assertEquals(300, newItems.size(), '300 new maintenance items should have been created');
    }
}
