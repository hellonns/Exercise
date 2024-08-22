import { LightningElement, api, track } from 'lwc';
import getRelatedRecordsCards from '@salesforce/apex/RelatedRecordsController.getRelatedRecordsCards';
import getRelatedRecordsTable from '@salesforce/apex/RelatedRecordsController.getRelatedRecordsTable';

export default class RelatedProjectTasksList extends LightningElement {
    @api recordId; // Project Id
    @api childObjectApiName;    //  = 'Project_Task__c';
    @api relationshipFieldName; // = 'Primary_Project__c'; // or 'Secondary_Project__c'
    @api fieldSetName;          //  = 'Task_Display_Fields';
    @api LabelText;
    @api showas;          //  = 'Table/Card';

    @track tasks = [];
    @track columns = [];
    @track error;
    @track count = 0;
    @track tableview = false;

    connectedCallback() {
        console.log('showas=====',this.showas);
        if(this.showas == 'Table'){
            this.loadTasksTable();
            this.tableview = true;
        }
        else    
            this.loadTasksCard();
    }

    // For Table VIEW
    async loadTasksTable() {
        try {
            const result = await getRelatedRecordsTable({
                childObjectApiName: this.childObjectApiName,
                relationshipFieldName: this.relationshipFieldName,
                fieldSetName: this.fieldSetName,
                parentId: this.recordId
            });
            console.log('result===',result);
            const fieldNames = result.fields;
            this.columns = this.createColumns(fieldNames);
            
            // Process records to merge fields and remove `fields` property
            this.tasks = [];
            for (let i = 0; i < result.records.length; i++) {
                let record = result.records[i];
                let mergedRecord = {};

                // Copy properties from the record
                for (let key in record) {
                    if (record.hasOwnProperty(key)) {
                        mergedRecord[key] = record[key];
                    }
                }

                // Merge properties from the fields map
                for (let field in record.fields) {
                    if (record.fields.hasOwnProperty(field)) {
                        mergedRecord[field] = record.fields[field];
                    }
                }

                // Remove the `fields` property
                delete mergedRecord.fields;
                console.log('mergedRecord===',mergedRecord);
                // Add the processed record to tasks
                this.tasks.push(mergedRecord);
            }
            
            this.count = this.tasks.length;
            console.log('columns===',this.columns);
            console.log('tasks===',this.tasks);
            console.log('count===',this.count);
        } catch (error) {
            console.log('error===',error)
            this.error = this.formatError(error); //  error ? ('ExceptionType : ' +error.body.exceptionType + ',\n Message :' +error.body.message+ ',\n  stackTrace' +error.body.stackTrace).replace(/\n/g, '<br>') : 'SOMETHING WENT WRONG' ;
        }
    }

    formatError(error) {
        // Format error to include line breaks if applicable
        return error.body.message
            ? (error.body.exceptionType + ',' +error.body.message)
            : 'An unknown error occurred.';
    }

    createColumns(fieldNames) {
        let columns = [];
        for (let i = 0; i < fieldNames.length; i++) {
            let fieldName = fieldNames[i];
            columns.push({
                label: this.formatLabel(fieldName),
                fieldName: fieldName,
                type: 'text'
            });
        }
        console.log('columns===',columns);
        return columns;
    }

    formatLabel(fieldName) {
        let formattedLabel = fieldName
            .replace(/_/g, ' ')  // Replace underscores with spaces
            .replace(/\b\w/g, char => char.toUpperCase());  // Capitalize first letter of each word
        console.log('formattedLabel===',formattedLabel);
        // Remove last character if it's 'C'
        if (formattedLabel.endsWith(' C')) {
            formattedLabel = formattedLabel.slice(0, -2); // Remove last 2 characters
        }
        
        return formattedLabel;
    }


    // For Card VIEW
    async loadTasksCard() {
        try {
            const result = await getRelatedRecordsCards({
                childObjectApiName: this.childObjectApiName,
                relationshipFieldName: this.relationshipFieldName,
                fieldSetName: this.fieldSetName,
                parentId: this.recordId
            });

            this.tasks = result;
        } catch (error) {
            this.error = this.formatError(error);
        }
    }
}