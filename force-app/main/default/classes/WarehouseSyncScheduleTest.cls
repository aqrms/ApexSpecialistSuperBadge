@isTest
private class WarehouseSyncScheduleTest {
    @isTest
    static void warehouseSyncScheduleTest() {
        Test.setMock(HttpCalloutMock.class, new WarehouseCalloutServiceMock());

        WarehouseSyncSchedule sc = new WarehouseSyncSchedule();
        Test.startTest();
        String jobId = System.schedule('WarehouseSyncScheduleJob', WarehouseSyncSchedule.CRON_EXP, sc);
        Test.stopTest();
        System.assert(jobId != null);
    }
}
