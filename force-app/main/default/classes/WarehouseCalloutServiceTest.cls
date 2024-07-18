@isTest
private class WarehouseCalloutServiceTest {
    @isTest
    static void testWarehouseCalloutService() {
        Test.setMock(HttpCalloutMock.class, new WarehouseCalloutServiceMock());

        Id jobId = System.enqueueJob(new WarehouseCalloutService());
        System.assert(jobId != null);
    }
}
