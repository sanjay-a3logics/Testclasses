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
private class LineItemDeleteTest {

    static testMethod void DeleteOnlyItem() {
        
     	Id pricebookId = Test.getStandardPricebookId();
		//Create product
		Product2 prod  = new Product2 
		(Name = 'TestProduct' 
		, IsActive = true
		,RevenueScheduleType='Divide'
		,RevenueInstallmentPeriod='Monthly'
		,Pricing_Method__c='CPM'
		,Objective__c='Brand'
		,NumberofRevenueInstallments=12
		,CanUseRevenueSchedule=true
		);
		
		insert prod;
		
		//Create pricebook entry
		PricebookEntry pbEntry = new PricebookEntry(
		Pricebook2Id = pricebookId,
		Product2Id = prod.Id,
		UnitPrice = 100.00,
		IsActive = true
		);
		insert pbEntry;
		
		Account A = new Account(Name='Davids Test');
		insert A;

        RecordType rt = [Select id from RecordType where name= 'Parent' and sObjectType= 'Opportunity' and isActive=true];
        RecordType rt1 = [Select id from RecordType where name= 'Flight' and sObjectType='Opportunity' and isActive=true];
        Date StartDate = date.newInstance(2016, 4, 15);
        Date EndDate = date.newInstance(2016, 6, 15);
        
        Date April = date.newInstance(2016, 4, 1);
        Date May = date.newInstance(2016, 5, 1);
        Date June = date.newInstance(2016, 6, 1);
        
        Opportunity parent = new Opportunity(AccountId= A.id,Name='Parent',RecordTypeID=rt.id , StageName='Closed Won', CloseDate=System.today());
        insert parent;
        OpportunityLineItem li = new OpportunityLineItem (UnitPrice=50,Quantity=1000
        ,Pricing_Method__c='CPM'
        ,pricebookEntryId=pbEntry.id,OpportunityId=parent.id
        ,ServiceDate=StartDate
        ,Campaign_end_date__C=EndDate
        
        );
        
        insert li;
        OpportunityLineItem insertedLI = [select id,opportunityID,serviceDate,unitPrice,QUantity,Pricing_method__c,campaign_end_Date__C from OpportunityLineItem
        where id=:li.id];
        
        
        OpportunityLineItemSchedule aprilLis = new OpportunityLineItemSchedule (OpportunityLineItemId=li.id, ScheduleDate=April, revenue=15000, Type='Revenue');
        OpportunityLineItemSchedule MayLis = new OpportunityLineItemSchedule (OpportunityLineItemId=li.id, ScheduleDate=May, revenue=20000, Type='Revenue');
        OpportunityLineItemSchedule JuneLis = new OpportunityLineItemSchedule (OpportunityLineItemId=li.id, ScheduleDate=June, revenue=15000, Type='Revenue');
        
        List<OpportunityLineItemSchedule> sched = new List<OpportunityLineItemSchedule>();
        sched.add(aprilLis);
        sched.add(MayLis);
        sched.add(JuneLis);
        
        AggregateResult[] futureOpportunitySpan = [Select OpportunityId,MIN(ServiceDate) minimum,MAX(Campaign_end_date__C) maximum from OpportunityLineItem where OpportunityId =:parent.id group by OpportunityId  ];

		
        insert sched; 
        
        Integer cnt = [Select COUNT() from Opportunity where Parent_Opportunity__c=:parent.id];
        System.assertEquals(3,cnt,'All 3 months not inserted COrrectly');
        
        delete li;
        Integer newCnt = [Select COUNT() from Opportunity where Parent_Opportunity__c=:parent.id];
        System.assertEquals(0,newCnt ,'All 3 children not deleted properly');
        
        
        
    }
}