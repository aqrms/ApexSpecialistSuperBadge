public with sharing class WarehouseCalloutService implements Queueable, Database.AllowsCallouts {
    private static final String WAREHOUSE_URL = 'https://th-superbadge-apex.herokuapp.com/equipment';

    public static void execute(QueueableContext context) {
        Http http = new Http();
        HttpRequest request = new HttpRequest();

        request.setMethod('GET');
        request.setEndpoint(WAREHOUSE_URL);

        HttpResponse response = http.send(request);

        if (response.getStatusCode() == 200) {
            List<Object> jsonResponse = (List<Object>) JSON.deserializeUntyped(response.getBody());
            List<Product2> productList = new List<Product2>();

            for (Object obj : jsonResponse) {
                Map<String, Object> jsonMap = (Map<String, Object>) obj;
                Product2 product = new Product2();
                product.Replacement_Part__c = (Boolean) jsonMap.get('replacement');
                product.Cost__c = (Decimal) jsonMap.get('cost');
                product.Current_Inventory__c = (Decimal) jsonMap.get('quantity');
                product.Lifespan_Months__c = (Decimal) jsonMap.get('lifespan');
                product.Maintenance_Cycle__c = (Decimal) jsonMap.get('maintenanceperiod');
                product.Warehouse_SKU__c = (String) jsonMap.get('sku');
                product.Name = (String) jsonMap.get('name');
                product.ProductCode = (String) jsonMap.get('_id');
                productList.add(product);
            }
            if (productList.size() > 0) {
                upsert productList;
            }
        }
    }
}
