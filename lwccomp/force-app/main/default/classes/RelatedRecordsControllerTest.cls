@isTest
public class RelatedRecordsControllerTest {
    
    @TestSetup
    static void setup() {
        // Create a Project
        Project__c primaryProject = new Project__c(Name = 'Primary Project');
        Project__c secondaryProject = new Project__c(Name = 'Secondary Project');
        insert primaryProject;
        insert secondaryProject;

        // Create Project Tasks related to the Project
        Project_Task__c task1 = new Project_Task__c(Name = 'Task 1', Primary_Project__c = primaryProject.Id, Due_Date__c = Date.Today().addDays(5), Status__c = 'New');
        Project_Task__c task2 = new Project_Task__c(Name = 'Task 2', Secondary_Project__c = secondaryProject.Id, Due_Date__c = Date.Today().addDays(-5), Status__c = 'Completed');
        insert task1;
        insert task2;
    }

    @isTest
    static void testGetRelatedRecords_ValidInputsForPrimary() {
        Test.startTest();
            Map<String, Object> result = RelatedRecordsController.getRelatedRecordsTable(
                'Project_Task__c', 
                'Primary_Project__c', 
                'Task_Display_Fields', 
                [Select Id From Project__c Where name = 'Primary Project' Limit 1].Id // parentId
            );

            List<Map<String, Object>> lstMapResult = RelatedRecordsController.getRelatedRecordsCards(
                'Project_Task__c', 
                'Primary_Project__c', 
                'Task_Display_Fields', 
                [Select Id From Project__c Where name = 'Primary Project' Limit 1].Id // parentId
            );
        Test.stopTest();
        List<Map<String, Object>> records = (List<Map<String, Object>>) result.get('records');
        System.assertEquals(1, records.size(), 'There should be one record in the result');
        System.assert(records[0].get('Id') != null, 'Record should have an Id');
        System.assert(records[0].get('Name') == 'Task 1', 'Record Name should match');
    }

    @isTest
    static void testGetRelatedRecords_ValidInputsForSecondary() {
        Test.startTest();
            Map<String, Object> result = RelatedRecordsController.getRelatedRecordsTable(
                'Project_Task__c', 
                'Secondary_Project__c', 
                'Task_Display_Fields',
                [Select Id From Project__c Where name = 'Secondary Project' Limit 1].Id // parentId
            );

            List<Map<String, Object>> lstMapResult = RelatedRecordsController.getRelatedRecordsCards(
                'Project_Task__c', 
                'Secondary_Project__c', 
                'Task_Display_Fields', 
                [Select Id From Project__c Where name = 'Primary Project' Limit 1].Id // parentId
            );
        Test.stopTest();
        
        system.debug('result=111==='+result);
        // Verify the results
        List<Map<String, Object>> records = (List<Map<String, Object>>) result.get('records');
        System.assertEquals(1, records.size(), 'There should be one record in the result');
        System.assert(records[0].get('Id') != null, 'Record should have an Id');
        System.assert(records[0].get('Name') == 'Task 2', 'Record Name should match');
    }
    
    @isTest
    static void testGetRelatedRecords_NoRecords() {
        Test.startTest();
            Map<String, Object> result = RelatedRecordsController.getRelatedRecordsTable(
                'Project_Task__c',
                'Primary_Project__c', 
                'Task_Display_Fields', 
                [Select Id From Project__c Where name = 'Secondary Project' Limit 1].Id 
            );
            List<Map<String, Object>> lstMapResult = RelatedRecordsController.getRelatedRecordsCards(
                    'Project_Task__c',
                    'Primary_Project__c', 
                    'Task_Display_Fields',
                    [Select Id From Project__c Where name = 'Primary Project' Limit 1].Id // parentId
            );
        Test.stopTest();
        
        system.debug('result==222=='+result);

        // Verify the results
        List<Map<String, Object>> records = (List<Map<String, Object>>) result.get('records');
        System.assertEquals(0, records.size(), 'There should be no records in the result');
    }
}