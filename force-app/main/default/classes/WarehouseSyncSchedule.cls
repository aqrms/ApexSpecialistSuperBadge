public with sharing class WarehouseSyncSchedule implements Schedulable {
    public static String CRON_EXP = '0 0 1 * * ?';

    public void execute(SchedulableContext sc) {
        System.enqueueJob(new WarehouseCalloutService());
    }
}
