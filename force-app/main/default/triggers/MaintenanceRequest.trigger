trigger MaintenanceRequest on Case(after update) {
    
    switch on Trigger.operationType {
        when AFTER_UPDATE {
            MaintenanceRequestHelper.createNextMaintenanceRequest(Trigger.new, Trigger.oldMap);
        }
    }
}
