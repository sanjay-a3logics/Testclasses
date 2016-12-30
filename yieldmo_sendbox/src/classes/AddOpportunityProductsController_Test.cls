@isTest
public class AddOpportunityProductsController_Test {
  
  @testSetup static void dataSetup(){
            
        // Test data setup								
        
        RecordType recType = [Select Id From RecordType where name='Provider' and SobjectType ='Account' Limit 1];
        
        Account accRec = new Account(RecordTypeId = recType.Id,  Name='Test');
        insert accRec;
        
        List<Product2> prodList = new List<Product2>();
        for(Integer i=1;i<=50;i++) {
          
           Product2 prod = new Product2(Name = 'Wrapper'+i, Pricing_Method__c='CPM', Objective__c='Brand', Provider_Account__c = accRec.Id,
                           CanUseQuantitySchedule =true, CanUseRevenueSchedule=true,IsActive=true,
                            Family = 'Yieldmo');        
           prodList.add(prod);
        }
        insert prodList;        
        
        Id pricebookId = Test.getStandardPricebookId();
       
        List<PricebookEntry> priceBookList = new List<PricebookEntry>();
        for(Product2 prod: prodList){
            PricebookEntry standardPrice = new PricebookEntry(Pricebook2Id = pricebookId, Product2Id = prod.Id,
                                               UnitPrice = 5, IsActive = true);
            priceBookList.add(standardPrice);
        }
        insert priceBookList;      
        
        Opportunity  oppObj = new Opportunity(Name='TestOpp', IO_Campaign_Start_Date__c=system.today(), 
                    IO_Campaign_End_Date__c=system.today().addMonths(4), StageName='Qualification', 
                    CloseDate=system.today().addDays(20), TotalOpportunityQuantity =100, Probability=10);
        insert oppObj;                
    }
  
  
    @isTest static void saveAndDoneUnitTest(){       
      
      Opportunity oppObj = [Select Id, Name, Pricebook2Id, IO_Campaign_Start_Date__c,IO_Campaign_End_Date__c From Opportunity Limit 1];
        
      Test.startTest();
      apexpages.currentpage().getparameters().put('id' , oppObj.Id); 
      AddOpportunityProductsController adpController = new AddOpportunityProductsController();        
      adpController.checkOpportunityPriceBook2();        
      
      adpController = new AddOpportunityProductsController();
      system.assert(adpController.lstMatchedProducts.size() == 50 );
            
      adpController.getCurrentRecordCount();
      adpController.getProductFieldFiltersOptions();
      adpController.addMoreFilters();
            
      adpController.lstFilterWrapper.get(0).filterByField = 'Product2.Name';
      adpController.lstFilterWrapper.get(0).filterByOperator = 'n';
      adpController.lstFilterWrapper.get(0).filterByValue = 'Wrapper1';          
      			      					
      adpController.searchProduct2();      
      
      system.assert(adpController.lstMatchedProducts.size() == 49);
      
      for(Integer i = 0; i < 5; i++ ){
        adpController.lstMatchedProducts.get( i ).isSelected = true;         
      }    
      
      adpController.createOpportunityLineItems();
      System.assert(adpController.lstOLIs.size() == 5);
      
      for(Integer i = 0; i < 5; i++ ){
        adpController.lstOLIs.get( i ).oliObj.Total_Price__c  = 10; 
        adpController.lstOLIs.get( i ).oliObj.Quantity = 2000;  
        adpController.lstOLIs.get( i ).oliObj.Position__c = 'Footer';
        adpController.lstOLIs.get( i ).oliObj.Objective__c = 'Brand';
        adpController.lstOLIs.get( i ).oliObj.Tier__c  = 'Brand';		
      }
      
      system.assert(adpController.lstOLIs[0].oliSchedules.size() == 0);
      
      adpController.saveAndFlight();      
      system.assert(adpController.lstOLIs[0].oliSchedules.size() == 5);
      
      //schedule is created after the saveAndFlight() Method called
      adpController.saveAndDone();      
      Test.stopTest();      
    }
    
    @isTest static void removeAllSelectedProductUnitTest(){       
      
	  Opportunity oppObj = [Select Id, Name, Pricebook2Id, IO_Campaign_Start_Date__c,IO_Campaign_End_Date__c From Opportunity Limit 1];
	    
	  Test.startTest();
	  apexpages.currentpage().getparameters().put('id' , oppObj.Id); 
	  AddOpportunityProductsController adpController = new AddOpportunityProductsController();        
      adpController.checkOpportunityPriceBook2();        
          
      adpController = new AddOpportunityProductsController();
      System.assert(adpController.lstMatchedProducts.size() == 50 );
            
      adpController.getCurrentRecordCount();
      adpController.getProductFieldFiltersOptions();
      adpController.addMoreFilters();
            
      adpController.lstFilterWrapper.get(0).filterByField = 'Product2.Name';
      adpController.lstFilterWrapper.get(0).filterByOperator = 'n';
      adpController.lstFilterWrapper.get(0).filterByValue = 'Wrapper1';        
      adpController.searchProduct2();      
      
      system.assert(adpController.lstMatchedProducts.size() == 49);
      
      for(Integer i = 0; i < 5; i++ ){
        adpController.lstMatchedProducts.get( i ).isSelected = true;         
      }    
      
      adpController.createOpportunityLineItems();
      System.assert(adpController.lstOLIs.size() == 5);
      
      for(Integer i = 0; i < 5; i++ ){
        adpController.lstOLIs.get( i ).oliObj.Total_Price__c  = 10; 
        adpController.lstOLIs.get( i ).oliObj.Quantity = 2000; 
        adpController.lstOLIs.get( i ).oliObj.Position__c = 'Footer';
        adpController.lstOLIs.get( i ).oliObj.Objective__c = 'Brand';
        adpController.lstOLIs.get( i ).oliObj.Tier__c  = 'Brand';		         
      }
      
      system.assert(adpController.lstOLIs[0].oliSchedules.size() == 0);
      
      adpController.saveAndFlight();      
      system.assert(adpController.lstOLIs[0].oliSchedules.size() == 5);
      
      adpController.productIndexToDelete =1;              
      adpController.resetProductFlight();  
      adpController.productIndexToDelete =1;
      adpController.removeSelectedProduct();  
      adpController.removeAllSelectedProduct();      
      Test.stopTest();      
    }
      
       
     @isTest static void searchFilterUnitTest() {       
      Opportunity oppObj = [Select Id, Name, Pricebook2Id, IO_Campaign_Start_Date__c,IO_Campaign_End_Date__c From Opportunity Limit 1];
            
      apexpages.currentpage().getparameters().put('id' , oppObj.Id); 
      AddOpportunityProductsController adpController = new AddOpportunityProductsController();        
      adpController.checkOpportunityPriceBook2();    
      
      adpController = new AddOpportunityProductsController();
      System.assert( adpController.lstMatchedProducts.size() == 50 );
      
      adpController.getCurrentRecordCount();
      adpController.getProductFieldFiltersOptions();
      adpController.addMoreFilters();
      
      for(Integer i = 0; i < 5; i++ ){
        adpController.lstMatchedProducts.get( i ).isSelected = true;         
      }    
      
      adpController.createOpportunityLineItems();
      System.assert(adpController.lstOLIs.size() == 5 );
      
      adpController.lstFilterWrapper.get(0).filterByField = 'Product2.Provider_Account__c';
      adpController.lstFilterWrapper.get(0).filterByOperator = 'u';
      adpController.lstFilterWrapper.get(0).filterByValue = '';    
      List<SelectOption> selOpts= adpController.lstFilterWrapper.get(0).FilterOperatorOptions;		
      adpController.searchProduct2();
      
      adpController.lstFilterWrapper.get(0).filterByOperator = 'x';
      adpController.searchProduct2();
      
      adpController.lstFilterWrapper.get(0).filterByOperator = 'w';
      adpController.searchProduct2();
            
      adpController.lstFilterWrapper.get(0).filterByField = 'PricebookEntry.CreatedDate';
      adpController.lstFilterWrapper.get(0).filterByOperator = 'e';
      adpController.lstFilterWrapper.get(0).filterByValue = '12/6/2016';    
      adpController.searchProduct2();
      
      adpController.lstFilterWrapper.get(0).filterByValue = '12/9/2016 6:34 AM';    
      adpController.searchProduct2();                
            
      adpController.lstFilterWrapper.get(0).filterByField = 'Product2.IsActive';
      adpController.lstFilterWrapper.get(0).filterByOperator = 'e';
      adpController.lstFilterWrapper.get(0).filterByValue = '0';                 
      adpController.searchProduct2();
      
      adpController.lstFilterWrapper.get(0).filterByValue = '1';       
      adpController.searchProduct2();
      
      adpController.lstFilterWrapper.get(0).filterByField = 'PriceBook2.Name';
      adpController.lstFilterWrapper.get(0).filterByOperator = 'k';    
      adpController.lstFilterWrapper.get(0).filterByValue = 'Standard Price Book,Standard Price Book1 ';      
      adpController.searchProduct2();
            
      adpController.lstFilterWrapper.get(0).filterByOperator = 'c';            
      adpController.searchProduct2();
        
      adpController.lstFilterWrapper.get(0).filterByOperator = 's';            
      adpController.searchProduct2();      
      
      adpController.lstFilterWrapper.get(0).filterByField = 'Product2.Family';
      adpController.lstFilterWrapper.get(0).filterByOperator = 'c';
      adpController.lstFilterWrapper.get(0).filterByValue = 'Yieldmo,Data,Measurement';      
      adpController.searchProduct2();
      
      adpController.lstFilterWrapper.get(0).filterByOperator = 'k';
      adpController.searchProduct2();
        
      adpController.lstFilterWrapper.get(0).filterByOperator = 's';
      adpController.searchProduct2();
      
      adpController.lstFilterWrapper.get(0).filterByOperator = 's';
      adpController.lstFilterWrapper.get(0).filterByValue = 'Y';
      adpController.searchProduct2();              
        
      adpController.lstFilterWrapper.get(0).filterByOperator = 'l';
      adpController.searchProduct2();
        
      adpController.lstFilterWrapper.get(0).filterByOperator = 'm';
      adpController.searchProduct2();
        
      adpController.lstFilterWrapper.get(0).filterByField = 'Product2.Name';
      adpController.lstFilterWrapper.get(0).filterByOperator = 'n';
      adpController.lstFilterWrapper.get(0).filterByValue = 'Wrapper';        
      adpController.searchProduct2();      
              
      adpController.lstFilterWrapper.get(0).filterByField = 'PricebookEntry.UnitPrice';
      adpController.lstFilterWrapper.get(0).filterByOperator = 'e';
      adpController.lstFilterWrapper.get(0).filterByValue = '2';        
      adpController.searchProduct2();      
          
      adpController.setFewFilters();    
      adpController.sortProducts();      
      
      boolean test1 = adpController.hasNext;
      boolean test2 = adpController.hasPrevious;
      integer test3 = adpController.pageNumber;
      
      adpController.first();
      adpController.last();
      adpController.next();  
      adpController.previous();
      adpController.cancel();
      adpController.cancelAddProduct();      
   }   
   
   @isTest static void negativeUnitTest(){       
      
      Opportunity oppObj = [Select Id, Name, Pricebook2Id, IO_Campaign_Start_Date__c,IO_Campaign_End_Date__c From Opportunity Limit 1];
        
      Test.startTest();
      apexpages.currentpage().getparameters().put('id' , oppObj.Id); 
      AddOpportunityProductsController adpController = new AddOpportunityProductsController();        
      adpController.checkOpportunityPriceBook2();        
          
      adpController = new AddOpportunityProductsController();
      System.assert(adpController.lstMatchedProducts.size() == 50 );
            
      adpController.getCurrentRecordCount();
      adpController.getProductFieldFiltersOptions();
      adpController.addMoreFilters();
            
      adpController.lstFilterWrapper.get(0).filterByField = 'Product2.Name';
      adpController.lstFilterWrapper.get(0).filterByOperator = 'n';
      adpController.lstFilterWrapper.get(0).filterByValue = 'Wrapper1';        
      adpController.searchProduct2();      
      
      system.assert(adpController.lstMatchedProducts.size() == 49);
      
      for(Integer i = 0; i < 5; i++ ){
        adpController.lstMatchedProducts.get( i ).isSelected = true;         
      }    
      
      adpController.createOpportunityLineItems();
      System.assert(adpController.lstOLIs.size() == 5);
      
      for(Integer i = 0; i < 5; i++ ){
        adpController.lstOLIs.get( i ).oliObj.ServiceDate  = null; 
        adpController.lstOLIs.get( i ).oliObj.Quantity = null;
        adpController.lstOLIs.get( i ).oliObj.ServiceDate = null;
        adpController.lstOLIs.get( i ).oliObj.UnitPrice = null;
        adpController.lstOLIs.get( i ).oliObj.Pricing_Method__c= null;
        adpController.lstOLIs.get( i ).oliObj.Campaign_End_Date__c = null;  
        adpController.lstOLIs.get( i ).oliObj.Position__c = null;
        adpController.lstOLIs.get( i ).oliObj.Objective__c = null;
        adpController.lstOLIs.get( i ).oliObj.Tier__c  = null;									
      }      
      
      system.assert(adpController.lstOLIs[0].oliSchedules.size() == 0);
      
      adpController.saveAndFlight();            
      adpController.productIndexToDelete =1;              
      adpController.resetProductFlight();  
      adpController.productIndexToDelete =1;
      adpController.removeSelectedProduct();  
      adpController.removeAllSelectedProduct();      
      Test.stopTest();      
    }
              
    @isTest static void negativeUnitTest1(){       
      Opportunity oppObj = [Select Id, Name, Pricebook2Id, IO_Campaign_Start_Date__c,IO_Campaign_End_Date__c From Opportunity Limit 1];
        
      Test.startTest();
      apexpages.currentpage().getparameters().put('id' , oppObj.Id); 
      AddOpportunityProductsController adpController = new AddOpportunityProductsController();   
      adpController.checkOpportunityPriceBook2();  
      
      adpController = new AddOpportunityProductsController();
      system.assert(adpController.lstMatchedProducts.size() == 50 );
            
      adpController.getCurrentRecordCount();
      adpController.getProductFieldFiltersOptions();
      adpController.addMoreFilters();
      
      adpController.keyworkSearchText = 'Wrapper1';      
      adpController.lstFilterWrapper.get(0).filterByField = 'Product2.Name';
      adpController.lstFilterWrapper.get(0).filterByOperator = 'e';
      adpController.lstFilterWrapper.get(0).filterByValue = 'Wrapper1';        
      adpController.searchProduct2();                      
      
      adpController.createOpportunityLineItems();                    
      Test.stopTest();            
  }   
  
}