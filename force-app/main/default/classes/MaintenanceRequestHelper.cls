public with sharing class MaintenanceRequestHelper {
    public static void createNextMaintenanceRequest(List<Case> closedRequest) {
        List<Case> nextMaintenanceRequest = new List<Case>();

        Map<Id, Integer> cycleMap = getMinCycleMap(closedRequest);

        for (Case c : closedRequest) {
            if (c.Type == 'Repair' || c.Type == 'Routine Maintenance') {
                Case newRequest = new Case(
                    Type = 'Routine Maintenance',
                    Vehicle__c = c.Vehicle__c,
                    Date_Reported__c = Date.today(),
                    Date_Due__c = Date.today().addDays(cycleMap.get(c.Id)),
                    Subject = 'Routine Checkup',
                    Status = 'New',
                    Origin = c.Origin,
                    ParentId = c.Id
                );

                nextMaintenanceRequest.add(newRequest);
            }
        }

        insert nextMaintenanceRequest;

        List<Equipment_Maintenance_item__c> newMaintenanceRequestItems = new List<Equipment_Maintenance_item__c>();

        List<Equipment_Maintenance_item__c> existingMaintenanceItems = [
            SELECT Id, Eqipment__c, Maintenance_Request__c
            FROM Equipment_Maintenance_Item__c
            WHERE Maintenance_Request__c IN :closedRequest
        ];

        for (Equipment_Maintenance_Item__c item : existingMaintenanceItems) {
            if (oldToNewCaseMap.containsKey(item.Maintenance_Request__c)) {
                Equipment_Maintenance_Item__c newItem = item.clone();
                newItem.Maintenance_Request__c = oldToNewCaseMap.get(item.Maintenance_Request__c).Id;
                newMaintenanceRequestItems.add(newItem);
            }
        }

        insert newMaintenanceRequestItems;
    }

    public static Map<Id, Integer> getMinCycleMap(List<Case> closedRequest) {
        List<AggregateResult> aggResults = [
            SELECT Maintenance_Request__c, MIN(Equipment__r.Maintenance_Cycle__c) minCycle
            FROM Equipment_Maintenance_Item__c
            WHERE Maintenance_Request__c IN :closedRequest
            GROUP BY Maintenance_Request__c
        ];

        Map<Id, Integer> cycleMap = new Map<Id, Integer>();
        for (AggregateResult aggRes : aggResults) {
            cycleMap.put((Id) aggRes.get('Maintenance_Request__c'), (Integer) aggRes.get('minCycle'));
        }

        return cycleMap;
    }
}
