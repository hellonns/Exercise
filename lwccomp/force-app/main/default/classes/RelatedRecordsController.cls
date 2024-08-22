public with sharing class RelatedRecordsController {
    @AuraEnabled(cacheable=true) // For TABLE VIEW
    public static Map<String, Object> getRelatedRecordsTable(String childObjectApiName, String relationshipFieldName, String fieldSetName, String parentId) {
        system.debug('childObjectApiName==='+childObjectApiName);
        system.debug('relationshipFieldName==='+relationshipFieldName);
        system.debug('fieldSetName==='+fieldSetName);
        system.debug('parentId==='+parentId);
        String query = 'SELECT ';
        List<String> fields = new List<String>();
        
        // Fetch the field set and build the list of fields to query
        Schema.FieldSet fieldSet = Schema.getGlobalDescribe().get(childObjectApiName).getDescribe().fieldSets.getMap().get(fieldSetName);
        List<String> fieldNames = new List<String>();
        for (Schema.FieldSetMember fsm : fieldSet.getFields()) {
            fieldNames.add(fsm.getFieldPath());
            fields.add(fsm.getFieldPath());
        }
        
        query += String.join(fields, ', ');
        query += ' FROM ' + childObjectApiName;
        query += ' WHERE ' + relationshipFieldName + ' =: parentId';
        
        // Execute the query
        List<SObject> records = Database.query(query);
        List<Map<String, Object>> results = new List<Map<String, Object>>();
        
        // Build results and include field names
        for (SObject record : records) {
            Map<String, Object> recordMap = new Map<String, Object>();
            recordMap.put('Id', record.get('Id'));
            recordMap.put('Name', record.get('Name'));
            
            Map<String, Object> fieldData = new Map<String, Object>();
            for (String field : fieldNames) {
                fieldData.put(field, record.get(field));
            }
            
            recordMap.put('fields', fieldData);
            results.add(recordMap);
        }
        system.debug('results==='+results);
        Map<String, Object> response = new Map<String, Object>();
        response.put('fields', fieldNames);
        response.put('records', results);
        system.debug('results==FINALLLL='+results);
        return response;
    }

    @AuraEnabled(cacheable=true) // For CARD VIEW
    public static List<Map<String, Object>> getRelatedRecordsCards(String childObjectApiName, String relationshipFieldName, String fieldSetName, String parentId) {
        String query = 'SELECT ';
        List<String> fields = new List<String>();

        Schema.FieldSet fieldSet = Schema.getGlobalDescribe().get(childObjectApiName).getDescribe().fieldSets.getMap().get(fieldSetName);
        for (Schema.FieldSetMember fsm : fieldSet.getFields()) {
            fields.add(fsm.getFieldPath());
        }
        query += String.join(fields, ', ');
        query += ' FROM ' + childObjectApiName;
        query += ' WHERE ' + relationshipFieldName + ' =: parentId';

        List<SObject> records = Database.query(query);
        List<Map<String, Object>> results = new List<Map<String, Object>>();

        for (SObject record : records) {
            Map<String, Object> recordMap = new Map<String, Object>();
            recordMap.put('Id', record.get('Id'));
            recordMap.put('Name', record.get('Name'));

            List<Map<String, Object>> fieldDataList = new List<Map<String, Object>>();
            for (String field : fields) {
                Map<String, Object> fieldData = new Map<String, Object>();
                fieldData.put('fieldPath', field);
                fieldData.put('data', record.get(field));
                fieldDataList.add(fieldData);
            }

            recordMap.put('fields', fieldDataList);
            results.add(recordMap);
        }

        return results;
    }
}