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
private class PartnerRelationshipTest {

 static testMethod void PartnerRelationshipNewOpportunityNoAgency() {
    	RecordType rt = [Select id from RecordType where name= 'Brand' and sObjectType= 'Account' and isActive=true];
        RecordType rt1 = [Select id from RecordType where name= 'Agency' and sObjectType='Account' and isActive=true];
        
        
        Account advertiser = new Account(Name='Test Advertiser',recordTypeId=rt.id) ;
        advertiser.recordType=rt;
        insert advertiser;
        
        
         
        
                
        Opportunity newOpp = new Opportunity(Name='Oppty1',AccountID =advertiser.id, StageName='Closed Won', CloseDate=System.today());
        insert newOpp;
        Integer recordCount= [Select count() from Partner where AccountFromId=:advertiser.id and role ='Billing Agency'];

        
        System.assertEquals(0,recordCount);
    }    
    
    static testMethod void PartnerRelationshipNewOpportunityNewAgency() {
    	RecordType rt = [Select id from RecordType where name= 'Brand' and sObjectType= 'Account' and isActive=true];
        RecordType rt1 = [Select id from RecordType where name= 'Agency' and sObjectType='Account' and isActive=true];
        
        
        Account advertiser = new Account(Name='Test Advertiser',recordTypeId=rt.id) ;
        advertiser.recordType=rt;
        insert advertiser;
        Account agency = new Account(Name='Test Agency-AAA', RecordTypeID=rt1.id);
        insert agency;
        
        agency = [Select Name,Id,RecordTypeId from Account where Name='Test Agency-AAA']; 
        
                
        Opportunity newOpp = new Opportunity(Name='Oppty1',AccountID =advertiser.id,Agency__c =agency.id, StageName='Closed Won', CloseDate=System.today());
        insert newOpp;
        Integer recordCount= [Select count() from Partner where AccountFromId=:advertiser.id and AccountToId=:agency.id and role ='Billing Agency'];

        
        System.assertEquals(1,recordCount);
    }    
    
    
     static testMethod void PartnerRelationshipNewOpportunity2Agencies() {
    	RecordType rt = [Select id from RecordType where name= 'Brand' and sObjectType= 'Account' and isActive=true];
        RecordType rt1 = [Select id from RecordType where name= 'Agency' and sObjectType='Account' and isActive=true];
        
        Account advertiser = new Account(Name='Test Advertiser') ;
        advertiser.recordType=rt;
        insert advertiser;
        Account agency = new Account(Name='Test Agency--BBB', RecordTypeID=rt1.id);
        insert agency;
        
        Account agency2 = new Account(Name='Test Agency--CCC', RecordTypeID=rt1.id);
        insert agency2;
        agency = [Select Name,Id,RecordTypeId from Account where Name='Test Agency--BBB'];
        agency2  = [Select Name,Id,RecordTypeId from Account where Name='Test Agency--CCC'];
        
        Opportunity newOpp = new Opportunity(Name='Oppty1',AccountID =advertiser.id,Agency__c =agency.id, StageName='Closed Won', CloseDate=System.today());
        insert newOpp;
        
        Opportunity newOpp1 = new Opportunity(Name='Oppty2',AccountID=advertiser.id,Agency__c =agency2.id , StageName='Closed Won', CloseDate=System.today());
        insert newOpp1;
        
        Integer recordCount = [Select count() from Partner where AccountFromId=:advertiser.id and AccountToId=:agency.id and role ='Billing Agency'];
        
        System.assertEquals(1,recordCount);
    }
         static testMethod void PartnerRelationshipNewOpportunity3Agencies() {
    	RecordType rt = [Select id from RecordType where name= 'Brand' and sObjectType= 'Account' and isActive=true];
        RecordType rt1 = [Select id from RecordType where name= 'Agency' and sObjectType='Account' and isActive=true];
        
        Account advertiser = new Account(Name='Test Advertiser') ;
        advertiser.recordType=rt;
        insert advertiser;
        Account agency = new Account(Name='Test Agency--BBB', RecordTypeID=rt1.id);
        insert agency;
        
        Account agency2 = new Account(Name='Test Agency--CCC', RecordTypeID=rt1.id);
        insert agency2;
        
        Account agency3 = new Account(Name='Test Agency--DDD', RecordTypeID=rt1.id);
        insert agency3;
        
        agency = [Select Name,Id,RecordTypeId from Account where Name='Test Agency--BBB'];
        agency2  = [Select Name,Id,RecordTypeId from Account where Name='Test Agency--CCC'];
        agency3  = [Select Name,Id,RecordTypeId from Account where Name='Test Agency--DDD'];
        
        Opportunity newOpp = new Opportunity(Name='Oppty1',AccountID =advertiser.id,Agency__c =agency.id, StageName='Closed Won', CloseDate=System.today());
        insert newOpp;
        
        Opportunity newOpp1 = new Opportunity(Name='Oppty2',AccountID=advertiser.id,Agency__c =agency2.id , StageName='Closed Won', CloseDate=System.today());
        insert newOpp1;
        
        Opportunity newOpp2 = new Opportunity(Name='Oppty2',AccountID=advertiser.id,Agency__c =agency3.id , StageName='Closed Won', CloseDate=System.today());
        insert newOpp2;
        
        Integer recordCount = [Select count() from Partner where AccountFromId=:advertiser.id and AccountToId=:agency.id and role ='Billing Agency'];
        Integer recordCount1 = [Select count() from Partner where AccountFromId=:advertiser.id and AccountToId=:agency2.id and role ='Billing Agency'];
        Integer recordCount2 = [Select count() from Partner where AccountFromId=:advertiser.id and AccountToId=:agency3.id and role ='Billing Agency'];
        
        
        System.assertEquals(1,recordCount);
        System.assertEquals(1,recordCount1);
        System.assertEquals(1,recordCount2);
    }
    
    static testMethod void PartnerRelationshipNewOpportunity2Advertisers1Agency() {
    	RecordType rt = [Select id from RecordType where name= 'Brand' and sObjectType= 'Account' and isActive=true];
        RecordType rt1 = [Select id from RecordType where name= 'Agency' and sObjectType='Account' and isActive=true];
        
        Account advertiser = new Account(Name='Test Advertiser 1',recordTypeID=rt.id) ;
        Account advertiser1 = new Account(Name='Test Advertiser 2',recordTypeID=rt.id) ;
        
        insert advertiser;
        insert advertiser1;
        
        advertiser = [Select Name,Id,RecordTypeId from Account where Name='Test Advertiser 1'];
        advertiser1 = [Select Name,Id,RecordTypeId from Account where Name='Test Advertiser 2'];
        
        Account agency = new Account(Name='Test Agency--BBB', RecordTypeID=rt1.id);
        insert agency;
        
        
        agency = [Select Name,Id,RecordTypeId from Account where Name='Test Agency--BBB'];
        
        
        Opportunity newOpp = new Opportunity(Name='Oppty1',AccountID =advertiser.id,Agency__c =agency.id, StageName='Closed Won', CloseDate=System.today());
        insert newOpp;
        
        Opportunity newOpp1 = new Opportunity(Name='Oppty2',AccountID=advertiser1.id,Agency__c =agency.id , StageName='Closed Won', CloseDate=System.today());
        insert newOpp1;
        
        Integer recordCount = [Select count() from Partner where AccountfromId=:advertiser.id and AccountToId=:agency.id and role ='Billing Agency'];
        Integer recordCount1 = [Select count() from Partner where AccountfromId=:advertiser1.id and AccountToId =:agency.id and role ='Billing Agency'];
        
        System.assertEquals(1,recordCount);
        System.assertEquals(1,recordCount1);
    }
    
    
    
    
    static testMethod void PartnerRelationshipNewOpportunityExistingAgency() {
    	RecordType rt = [Select id from RecordType where name= 'Brand' and sObjectType= 'Account' and isActive=true];
        RecordType rt1 = [Select id from RecordType where name= 'Agency' and sObjectType='Account' and isActive=true];
        
        Account advertiser = new Account(Name='Test Advertiser') ;
        advertiser.recordType=rt;
        insert advertiser;
        Account agency = new Account(Name='Test Agency--BBB', RecordTypeID=rt1.id);
        insert agency;
        
        agency = [Select Name,Id,RecordTypeId from Account where Name='Test Agency--BBB'];
        
        Opportunity newOpp = new Opportunity(Name='Oppty1',AccountID =advertiser.id,Agency__c =agency.id, StageName='Closed Won', CloseDate=System.today());
        insert newOpp;
        
        Opportunity newOpp1 = new Opportunity(Name='Oppty2',AccountID=advertiser.id,Agency__c =agency.id , StageName='Closed Won', CloseDate=System.today());
        insert newOpp1;
        
        Integer recordCount = [Select count() from Partner where AccountfromId=:advertiser.id and AccountToId=:agency.id and role ='Billing Agency'];
        
        System.assertEquals(1,recordCount);
    }
    
        static testMethod void PartnerRelationshipUpdateOpportunityNewAgency() {
    	RecordType rt = [Select id from RecordType where name= 'Brand' and sObjectType= 'Account' and isActive=true];
        RecordType rt1 = [Select id from RecordType where name= 'Agency' and sObjectType='Account' and isActive=true];
        
        Account advertiser = new Account(Name='Test Advertiser',RecordTypeID=rt.id) ;
        advertiser.recordType=rt;
        insert advertiser;
        Account agency = new Account(Name='Test Agency', RecordTypeID=rt1.id);
        insert agency;
        
        Account agency2 = new Account(Name='Test Agency 2', RecordTypeID=rt1.id);
        insert agency2;
        
        
        
        Opportunity newOpp = new Opportunity(Name='Oppty1',AccountID =advertiser.id,Agency__c =agency.id, StageName='Closed Won', CloseDate=System.today());
        insert newOpp;
        
        newOpp.Agency__c=agency2.id;
        update newOpp;
        
        
        Integer recordCount1= [Select count() from Partner where AccountFromId=:advertiser.id and AccountToId=:agency.id and role ='Billing Agency'];
        Integer recordCount2= [Select count() from Partner where AccountFromId=:advertiser.id and AccountToId=:agency2.id and role ='Billing Agency'];
        
        
        System.assertEquals(1,recordCount1);
        System.assertEquals(1,recordCount2);
    }
}