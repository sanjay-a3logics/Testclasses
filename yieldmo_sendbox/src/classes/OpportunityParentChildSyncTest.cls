/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class OpportunityParentChildSyncTest {

    static testMethod void ChangeStage() {
        
        RecordType rt = [Select id from RecordType where name= 'Parent' and sObjectType= 'Opportunity' and isActive=true];
        RecordType rt1 = [Select id from RecordType where name= 'Flight' and sObjectType='Opportunity' and isActive=true];
        
        Opportunity parent = new Opportunity(Name='Parent',RecordTypeID=rt.id , StageName='Closed Lost',Lost_Reason__c='Price' , CloseDate=System.today());
        
        insert parent;
        
        Opportunity child1= new Opportunity(Name='Child1',RecordTypeID=rt1.id , StageName='Closed Lost-Child' ,Lost_Reason__c='Price' , CloseDate=System.today(), Parent_Opportunity__c = parent.id);
        Opportunity child2= new Opportunity(Name='Child2',RecordTypeID=rt1.id , StageName='Closed Lost-Child' ,Lost_Reason__c='Price' , CloseDate=System.today(), Parent_Opportunity__c = parent.id);
        Opportunity child3= new Opportunity(Name='Child3',RecordTypeID=rt1.id , StageName='Closed Lost-Child' ,Lost_Reason__c='Price' , CloseDate=System.today(), Parent_Opportunity__c = parent.id);
        
        
        insert child1;
        insert child2;
        insert child3;
        
        
        parent = [Select id,StageName from Opportunity where id=:parent.id];
        parent.StageName = 'Closed Won';
        system.debug('begin Update');
        update parent;
        
        child1 = [Select id,StageName,Lost_reason__C from Opportunity where id=:child1.id];
        child2 = [Select id,StageName,Lost_reason__C from Opportunity where id=:child2.id];
        child3 = [Select id,StageName,Lost_reason__C from Opportunity where id=:child3.id];
        
        System.assertEquals('Closed Won-Child',child1.StageName);
        System.assertEquals('Closed Won-Child',child2.StageName);
        System.assertEquals('Closed Won-Child',child3.StageName);        
        System.assertEquals(null,child3.Lost_reason__C,'Lost reason not nulled out');
        
    }
}