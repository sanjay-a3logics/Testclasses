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
private class OppScheduleTest {

static testMethod void SingleNewItem() {
    	
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
        System.debug('Parent LI ID should be:'+li.id);
        OpportunityLineItemSchedule aprilLis = new OpportunityLineItemSchedule (OpportunityLineItemId=li.id, ScheduleDate=April, revenue=15000, Type='Revenue');
        OpportunityLineItemSchedule MayLis = new OpportunityLineItemSchedule (OpportunityLineItemId=li.id, ScheduleDate=May, revenue=20000, Type='Revenue');
        OpportunityLineItemSchedule JuneLis = new OpportunityLineItemSchedule (OpportunityLineItemId=li.id, ScheduleDate=June, revenue=15000, Type='Revenue');
        
        List<OpportunityLineItemSchedule> sched = new List<OpportunityLineItemSchedule>();
        sched.add(aprilLis);
        sched.add(MayLis);
        sched.add(JuneLis);
        
        insert sched; 
        
        Opportunity parent1 = [Select id,closedate,amount,ownerId from Opportunity  
        where ID =: parent.id];
        
        
        
        
        List<Opportunity> results = [Select id,closedate,amount,ownerId from Opportunity  
        where RecordTypeId=:rt1.id and Parent_Opportunity__c =: parent.id];
        
        boolean foundApril=false;
        boolean foundMay=false;
        boolean foundJune=false;
        
        System.debug(results);
        for(Integer i=0;i<results.Size();i++)
        {
        	Opportunity o1 = results.get(i);
        	if(o1.closedate == date.newInstance(2016, 4, 1)) {
        		if(o1.amount==15000){
        			foundAPril=true;
        		}
        		System.debug('FOUND APRIL' + o1 );
        		
        		Integer cnt = [Select COUNT() from opportunityLineItem where opportunityId=:o1.id];
        		System.assertEquals(1,cnt,'Missing April Line Item');
        		List<opportunityLineItem> oppLineList =[Select ParentOpportunityLineItemId__c from opportunityLineItem where opportunityId=:o1.id];
        		for(opportunityLineItem oli:oppLineList )
        		{
        			System.assertEquals(li.id,oli.ParentOpportunityLineItemId__c,'April Not set to correct parent');
        		}
        		
        		System.assertEquals(parent1.ownerId, o1.ownerID,'Parents Dont Match');
        	}
        	if(o1.closedate == date.newInstance(2016, 5, 1)) {
        		if(o1.amount==20000){
        			foundMay=true;
        		}
        		Integer cnt = [Select COUNT() from opportunityLineItem where opportunityId=:o1.id];
        		System.assertEquals(1,cnt,'Missing May Line Item');
        	}
        	if(o1.closedate == date.newInstance(2016, 6, 1)) {
        		if(o1.amount==15000){
        			foundJune=true;
        		}
        		Integer cnt = [Select COUNT() from opportunityLineItem where opportunityId=:o1.id];
        		System.assertEquals(1,cnt,'Missing June Line Item');
        	}
        	
        }
        System.assert(foundApril,'Missed Initial April');
        System.assert(foundMay,'Missed Initial May');
        System.assert(foundJune,'Missed Initial June');        
        
        
        
        
    }
    
    static testMethod void UpdateSingleItem() {
    	
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
        ,ServiceDate =StartDate
        ,Campaign_end_date__C=EndDate
        
        );
        
        insert li;
        
        OpportunityLineItemSchedule aprilLis = new OpportunityLineItemSchedule (OpportunityLineItemId=li.id, ScheduleDate=April, revenue=15000, Type='Revenue');
        OpportunityLineItemSchedule MayLis = new OpportunityLineItemSchedule (OpportunityLineItemId=li.id, ScheduleDate=May, revenue=20000, Type='Revenue');
        OpportunityLineItemSchedule JuneLis = new OpportunityLineItemSchedule (OpportunityLineItemId=li.id, ScheduleDate=June, revenue=15000, Type='Revenue');
        
        List<OpportunityLineItemSchedule> sched = new List<OpportunityLineItemSchedule>();
        sched.add(aprilLis);
        sched.add(MayLis);
        sched.add(JuneLis);
        
        insert sched; 
        
        
        List<Opportunity> results = [Select id,closedate,amount from Opportunity  
        where RecordTypeId=:rt1.id and Parent_Opportunity__c =: parent.id];
        
        boolean foundApril=false;
        boolean foundMay=false;
        boolean foundJune=false;
        
        
        
        aprilLis.revenue=18000;
        MayLis.revenue=17000;
        
        list<OpportunityLineItemSchedule> schedules = new List<OpportunityLineItemSchedule> (); 
        schedules.add(aprilLis);
        schedules.add(MayLis);
        update schedules;
        
        results = [Select id,closedate,amount from Opportunity  
        where RecordTypeId=:rt1.id and Parent_Opportunity__c =: parent.id];
        
         foundApril=false;
        foundMay=false;
        foundJune=false;
        
        
        for(Integer i=0;i<results.Size();i++)
        {
        	Opportunity o1 = results.get(i);
        	if(o1.closedate == date.newInstance(2016, 4, 1)) {
        		if(o1.amount==18000){
        			foundAPril=true;
        		}
        		Integer cnt = [Select COUNT() from opportunityLineItem where opportunityId=:o1.id];
        		System.assertEquals(1,cnt,'Missing Secondary April Line Item');
        	}
        	if(o1.closedate == date.newInstance(2016, 5, 1)) {
        		if(o1.amount==17000){
        			foundMay=true;
        		}
        		Integer cnt = [Select COUNT() from opportunityLineItem where opportunityId=:o1.id];
        		System.assertEquals(1,cnt,'Missing Secondary May Line Item');
        	}
        	if(o1.closedate == date.newInstance(2016, 6, 1)) {
        		if(o1.amount==15000){
        			foundJune=true;
        		}
        		Integer cnt = [Select COUNT() from opportunityLineItem where opportunityId=:o1.id];
        		System.assertEquals(1,cnt,'Missing Secondary June Line Item');
        	}
        	
        }
        System.assert(foundApril,'Missed Updated April');
        System.assert(foundMay,'Missed Updated May');
        System.assert(foundJune,'Missed Updated June');  
        
        
    }
    static testMethod void UpdateShortenedSingleItem() {
    	
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
        ,ServiceDate =StartDate
        ,Campaign_end_date__C=EndDate
        
        );
        
        insert li;
        
        OpportunityLineItemSchedule aprilLis = new OpportunityLineItemSchedule (OpportunityLineItemId=li.id, ScheduleDate=April, revenue=15000, Type='Revenue');
        OpportunityLineItemSchedule MayLis = new OpportunityLineItemSchedule (OpportunityLineItemId=li.id, ScheduleDate=May, revenue=20000, Type='Revenue');
        OpportunityLineItemSchedule JuneLis = new OpportunityLineItemSchedule (OpportunityLineItemId=li.id, ScheduleDate=June, revenue=15000, Type='Revenue');
        
        List<OpportunityLineItemSchedule> sched = new List<OpportunityLineItemSchedule>();
        sched.add(aprilLis);
        sched.add(MayLis);
        sched.add(JuneLis);
        
        insert sched; 
        
        
        
        aprilLis =[Select id from OpportunityLineItemSchedule where scheduleDate=:April];
        
        
        
        
        delete aprilLis;
        
        li.ServiceDate = StartDate.addMonths(1);
        li.UnitPrice=35;
        li.quantity=1000;
        
        
        
        
        
        boolean deletedApril=false;
        boolean foundMay=false;
        boolean foundJune=false;
        
        
        
        
        List<Opportunity> results = [Select id,closedate,amount from Opportunity  
        where RecordTypeId=:rt1.id and Parent_Opportunity__c =: parent.id];
        

        
        
        for(Integer i=0;i<results.Size();i++)
        {
        	Opportunity o1 = results.get(i);
        	if(o1.closedate == date.newInstance(2016, 4, 1)) {
        		if(o1.amount==0){
        			deletedApril=true;
        		}
        		Integer cnt = [Select COUNT() from opportunityLineItem where opportunityId=:o1.id];
        		System.assertEquals(0,cnt,'Deleted Secondary April Line Item');
        	}
        	if(o1.closedate == date.newInstance(2016, 5, 1)) {
        		if(o1.amount==20000){
        			foundMay=true;
        		}
        		Integer cnt = [Select COUNT() from opportunityLineItem where opportunityId=:o1.id];
        		System.assertEquals(1,cnt,'Missing Secondary May Line Item');
        	}
        	if(o1.closedate == date.newInstance(2016, 6, 1)) {
        		if(o1.amount==15000){
        			foundJune=true;
        		}
        		Integer cnt = [Select COUNT() from opportunityLineItem where opportunityId=:o1.id];
        		System.assertEquals(1,cnt,'Missing Secondary June Line Item');
        	}
        	
        }
        System.assert(deletedApril,'Missed April Delete');
        System.assert(foundMay,'Missed Updated May');
        System.assert(foundJune,'Missed Updated June');  
        
        
    }
    static testMethod void UpdateLaterSingleItem() {
    	
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
        Date NewEndDate = date.newInstance(2016, 7, 15);
        
        Date April = date.newInstance(2016, 4, 1);
        Date May = date.newInstance(2016, 5, 1);
        Date June = date.newInstance(2016, 6, 1);
        Date July = date.newInstance(2016, 7, 1);
        
        Opportunity parent = new Opportunity(AccountId= A.id,Name='Parent',RecordTypeID=rt.id , StageName='Closed Won', CloseDate=System.today());
        insert parent;
        OpportunityLineItem li = new OpportunityLineItem (UnitPrice=50,Quantity=1000
        ,Pricing_Method__c='CPM'
        ,pricebookEntryId=pbEntry.id,OpportunityId=parent.id
        ,ServiceDate =StartDate
        ,Campaign_end_date__C=EndDate
        
        );
        
        insert li;
        
        OpportunityLineItemSchedule aprilLis = new OpportunityLineItemSchedule (OpportunityLineItemId=li.id, ScheduleDate=April, revenue=15000, Type='Revenue');
        OpportunityLineItemSchedule MayLis = new OpportunityLineItemSchedule (OpportunityLineItemId=li.id, ScheduleDate=May, revenue=20000, Type='Revenue');
        OpportunityLineItemSchedule JuneLis = new OpportunityLineItemSchedule (OpportunityLineItemId=li.id, ScheduleDate=June, revenue=15000, Type='Revenue');
        
        List<OpportunityLineItemSchedule> sched = new List<OpportunityLineItemSchedule>();
        sched.add(aprilLis);
        sched.add(MayLis);
        sched.add(JuneLis);
        
        insert sched; 
        
        
        
        OpportunityLineItemSchedule JulyLis = new OpportunityLineItemSchedule (OpportunityLineItemId=li.id, ScheduleDate=July, revenue=10000, Type='Revenue');
        
        insert JulyLis ;
        List<OpportunityLineItemSchedule> scheduleNow = [select id,scheduleDate,revenue from OpportunityLineItemSchedule where  OpportunityLineItemId=:li.id];
		System.debug('-----------');
		System.debug('ScheduleNow : '+ScheduleNow);        
        
        li.Campaign_end_date__C=NewEndDate;
        update li;
        
        
        boolean foundApril=false;
        boolean foundMay=false;
        boolean foundJune=false;
        boolean foundJuly=false;
        
        
        
        
        List<Opportunity> results = [Select id,closedate,amount from Opportunity  
        where RecordTypeId=:rt1.id and Parent_Opportunity__c =: parent.id];
        
		System.debug('Child OppResults:' +results);
        
        
        for(Integer i=0;i<results.Size();i++)
        {
        	Opportunity o1 = results.get(i);
        	if(o1.closedate == date.newInstance(2016, 4, 1)) {
        		if(o1.amount==15000){
        			foundApril=true;
        		}
        		Integer cnt = [Select COUNT() from opportunityLineItem where opportunityId=:o1.id];
        		System.assertEquals(1,cnt,'Missing Secondary May Line Item');
        	}
        	if(o1.closedate == date.newInstance(2016, 5, 1)) {
        		if(o1.amount==20000){
        			foundMay=true;
        		}
        		Integer cnt = [Select COUNT() from opportunityLineItem where opportunityId=:o1.id];
        		System.assertEquals(1,cnt,'Missing Secondary May Line Item');
        	}
        	if(o1.closedate == date.newInstance(2016, 6, 1)) {
        		if(o1.amount==15000){
        			foundJune=true;
        		}
        		Integer cnt = [Select COUNT() from opportunityLineItem where opportunityId=:o1.id];
        		System.assertEquals(1,cnt,'Missing Secondary June Line Item');
        	}
        	if(o1.closedate == date.newInstance(2016, 7, 1)) {
        		System.debug('found july:' + o1);
        		if(o1.amount==10000){
        			foundJuly=true;
        		}
        		Integer cnt = [Select COUNT() from opportunityLineItem where opportunityId=:o1.id];
        		System.assertEquals(1,cnt,'Missing Secondary July Line Item');
        	}
        	
        }
        System.assert(foundApril,'Missed Updated April');
        System.assert(foundMay,'Missed Updated May');
        System.assert(foundJune,'Missed Updated June');  
        System.assert(foundJuly,'Missed Updated July');
        
        
    }
    
    static testMethod void UpdateEarlierSingleItem() {
    	
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
        Date NewEndDate = date.newInstance(2016, 7, 15);
        Date NewStartDate = date.newInstance(2016, 3, 15);
        
        Date March = date.newInstance(2016, 3, 1);
        Date April = date.newInstance(2016, 4, 1);
        Date May = date.newInstance(2016, 5, 1);
        Date June = date.newInstance(2016, 6, 1);
        Date July = date.newInstance(2016, 7, 1);
        
        Opportunity parent = new Opportunity(AccountId= A.id,Name='Parent',RecordTypeID=rt.id , StageName='Closed Won', CloseDate=System.today());
        insert parent;
        OpportunityLineItem li = new OpportunityLineItem (UnitPrice=50,Quantity=1000
        ,Pricing_Method__c='CPM'
        ,pricebookEntryId=pbEntry.id,OpportunityId=parent.id
        ,ServiceDate =StartDate
        ,Campaign_end_date__C=EndDate
        
        );
        
        insert li;
        
        OpportunityLineItemSchedule aprilLis = new OpportunityLineItemSchedule (OpportunityLineItemId=li.id, ScheduleDate=April, revenue=15000, Type='Revenue');
        OpportunityLineItemSchedule MayLis = new OpportunityLineItemSchedule (OpportunityLineItemId=li.id, ScheduleDate=May, revenue=20000, Type='Revenue');
        OpportunityLineItemSchedule JuneLis = new OpportunityLineItemSchedule (OpportunityLineItemId=li.id, ScheduleDate=June, revenue=15000, Type='Revenue');
        
        List<OpportunityLineItemSchedule> sched = new List<OpportunityLineItemSchedule>();
        sched.add(aprilLis);
        sched.add(MayLis);
        sched.add(JuneLis);
        
        insert sched; 
        
        
        
        OpportunityLineItemSchedule MarchLis = new OpportunityLineItemSchedule (OpportunityLineItemId=li.id, ScheduleDate=March, revenue=10000, Type='Revenue');
        
        insert MarchLis ;
        List<OpportunityLineItemSchedule> scheduleNow = [select id,scheduleDate,revenue from OpportunityLineItemSchedule where  OpportunityLineItemId=:li.id];
		System.debug('-----------');
		System.debug('ScheduleNow : '+ScheduleNow);        
        
        li.ServiceDate =NewStartDate;
        update li;
        
        
        boolean foundApril=false;
        boolean foundMay=false;
        boolean foundJune=false;
        boolean foundMarch=false;
        
        
        
        
        List<Opportunity> results = [Select id,closedate,amount from Opportunity  
        where RecordTypeId=:rt1.id and Parent_Opportunity__c =: parent.id];
        
		System.debug('Child OppResults:' +results);
        
        
        for(Integer i=0;i<results.Size();i++)
        {
        	Opportunity o1 = results.get(i);
        	if(o1.closedate == date.newInstance(2016, 4, 1)) {
        		if(o1.amount==15000){
        			foundApril=true;
        		}
        		Integer cnt = [Select COUNT() from opportunityLineItem where opportunityId=:o1.id];
        		System.assertEquals(1,cnt,'Missing Secondary May Line Item');
        	}
        	if(o1.closedate == date.newInstance(2016, 5, 1)) {
        		if(o1.amount==20000){
        			foundMay=true;
        		}
        		Integer cnt = [Select COUNT() from opportunityLineItem where opportunityId=:o1.id];
        		System.assertEquals(1,cnt,'Missing Secondary May Line Item');
        	}
        	if(o1.closedate == date.newInstance(2016, 6, 1)) {
        		if(o1.amount==15000){
        			foundJune=true;
        		}
        		Integer cnt = [Select COUNT() from opportunityLineItem where opportunityId=:o1.id];
        		System.assertEquals(1,cnt,'Missing Secondary June Line Item');
        	}
        	if(o1.closedate == date.newInstance(2016, 3, 1)) {
        		
        		if(o1.amount==10000){
        			foundMarch=true;
        		}
        		Integer cnt = [Select COUNT() from opportunityLineItem where opportunityId=:o1.id];
        		System.assertEquals(1,cnt,'Missing Secondary March Line Item');
        	}
        	
        }
        System.assert(foundMarch,'Missed insert March');
        System.assert(foundApril,'Missed Updated April');
        System.assert(foundMay,'Missed Updated May');
        System.assert(foundJune,'Missed Updated June');  
        
        
        
    }
}