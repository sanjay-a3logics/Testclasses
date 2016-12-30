public with sharing class AddOpportunityProductsController {
    
    private static final Integer PAGE_SIZE = 50;
    
    public Boolean showSearchPanel{get;set;}
    public Boolean showSaveAndDone{get;set;}
    
    public String keyworkSearchText{get;set;}
    public String sortByField{get;set;}
    public String sortByOrder{get;set;}
    public String productSearchQuery{get;set;}
    
    public Integer productIndexToDelete{get;set;}
    
    private Opportunity opportunityObj{get;set;}
    
    public list<Id> selectedPriceBookEntries{get;set;}
    
    public list<FilterWrapper> lstFilterWrapper{ get;set; }
    public list<ProductsWrapper> lstMatchedProducts{get;set;}
    public list<OpportunityLineItemWrapper> lstOLIs{get{ 
        return lstOLIs == null ? new list<OpportunityLineItemWrapper>() : lstOLIs;
    }set;}
    
    public ApexPages.StandardSetController con {
        get;set;
    }
    
    public AddOpportunityProductsController(){
        
        try{
            Id oppId = ApexPages.currentPage().getParameters().get('id');
            if( oppId != null ){
                opportunityObj = [SELECT o.Pricebook2Id, o.Name, o.Id, o.IO_Campaign_Start_Date__c, o.IO_Campaign_End_Date__c From Opportunity o WHERE Id=:oppId limit 1 ];
                if( opportunityObj.Pricebook2Id != null ){
	            	showSaveAndDone = false;
			        showSearchPanel = true;
			        sortByField = 'Product2.Name';
			        sortByOrder = 'asc';
			        productSearchQuery = '';
			        selectedPriceBookEntries = new list<Id>();
			        
			        lstOLIs = new list<OpportunityLineItemWrapper>();
			        
			        lstFilterWrapper = new list<FilterWrapper>();
			        lstFilterWrapper.add( new FilterWrapper( this ) );
			        searchProduct2();
            	}
            }
        }catch( Exception e ){
            return;
        }    
        
    }
    
    public PageReference checkOpportunityPriceBook2(){
    	Id oppId = ApexPages.currentPage().getParameters().get('id');
        if( oppId != null ){
            Opportunity opportunityObj = [SELECT o.Pricebook2Id, Id From Opportunity o WHERE Id=:oppId limit 1 ];
            if( opportunityObj.Pricebook2Id == null ){
            	//return new PageReference('/oppitm/choosepricebook.jsp?id='+opportunityObj.Id+'&retURL=%2F'+opportunityObj.Id+'&saveURL=%2Fapex%2FAddOpportunityProducts%3Fid%3D'+opportunityObj.Id);
        		Id standardPriceBookId = null;
        		if( !Test.isRunningTest() ){
        			PriceBook2 standardPriceBook = [Select p.IsStandard, p.Id From Pricebook2 p limit 1];
        			standardPriceBookId = standardPriceBook.Id;
        		}else{
        			standardPriceBookId = Test.getStandardPriceBookId();
        		}
        		opportunityObj.Pricebook2Id = standardPriceBookId;
        		update opportunityObj;
        		
        		return new PageReference('/apex/AddOpportunityProducts?id='+opportunityObj.Id).setRedirect(true);
        	}
        }else{
        	return new PageReference('/');
        }
        return null;
    }
    
    // indicates whether there are more records after the current page set.
    public Boolean hasNext {
        get {
            return con.getHasNext();
        }
        set;
    }

    // indicates whether there are more records before the current page set.
    public Boolean hasPrevious {
        get {
            return con.getHasPrevious();
        }
        set;
    }

    // returns the page number of the current page set
    public Integer pageNumber {
        get {
            return con.getPageNumber();
        }
        set;
    }
    
    public String getCurrentRecordCount(){
    	Integer NumberOfRecords = getNumberOfRecords();
    	Decimal NumberOfPages = getNumberOfPages();
    	Integer currentPageSize = con.getRecords().size();
    	return ( NumberOfPages == 1 ? ( '1 - '+NumberOfRecords+' of '+ NumberOfRecords ) : ( pageNumber == 1 ? '1 - '+PAGE_SIZE+' of '+NumberOfRecords : ( ( (pageNumber-1) * PAGE_SIZE ) + 1 )+' - '+((PAGE_SIZE*pageNumber) > NumberOfRecords ? (PAGE_SIZE*(pageNumber-1)) + currentPageSize : (PAGE_SIZE*pageNumber))+' Of '+ NumberOfRecords ) );
    } 
    
    public Integer getNumberOfRecords(){
    	return con.getResultSize();
    }
    
    public Decimal getNumberOfPages(){
    	return (con.getResultSize()/ (Decimal)PAGE_SIZE ).round(System.RoundingMode.CEILING);
    }
    

    // returns the first page of records
    public void first() {
        collectSelectedPriceBookEntries();
        con.first();
        populateProducts();
    }
    
    // returns the last page of records
    public void last() {
        collectSelectedPriceBookEntries();
        con.last();
        populateProducts();
    }

    // returns the previous page of records
    public void previous() {
        collectSelectedPriceBookEntries();
        con.previous();
        populateProducts();
    }

    // returns the next page of records
    public void next() {
        collectSelectedPriceBookEntries();
        con.next();
        populateProducts();
    }

    // returns the PageReference of the original page, if known, or the home page.
    public void cancel() {
        con.cancel();
    }
    
    private void populateProducts(){
        lstMatchedProducts = new list<ProductsWrapper>();
        System.debug('---> inside populateProducts');
        set<Id> setSelectedPriceBookEntries = new set<Id>();
        setSelectedPriceBookEntries.addAll( selectedPriceBookEntries );
        for( PriceBookEntry pbeObj : (List<PriceBookEntry>)con.getRecords() ){
            if( setSelectedPriceBookEntries.contains( pbeObj.Id ) ){
                lstMatchedProducts.add( new ProductsWrapper( pbeObj, true ) );
            }else{
                lstMatchedProducts.add( new ProductsWrapper( pbeObj, false ) );
            }
        }
    }
    
    private void collectSelectedPriceBookEntries(){
    	/*set<Id> setSelectedPriceBookEntries = new set<Id>();
        setSelectedPriceBookEntries.addAll( selectedPriceBookEntries );*/
        for( ProductsWrapper obj : lstMatchedProducts ) {
            if( obj.isSelected ){
                selectedPriceBookEntries.add( obj.pbeObj.Id );
            }/*else if( selectedPriceBookEntries.contains( obj.pbeObj.Id ) ){
                selectedPriceBookEntries.remove( obj.pbeObj.Id ) ;
            }*/
        }
        
        //System.debug('----> collectSelectedPriceBookEntries selectedPriceBookEntries: '+selectedPriceBookEntries.size()+'\tvalues: '+selectedPriceBookEntries);
        
    }
    
    public void addMoreFilters(){
        lstFilterWrapper.add( new FilterWrapper( this ) );
        lstFilterWrapper.add( new FilterWrapper( this ) );
        lstFilterWrapper.add( new FilterWrapper( this ) );
        lstFilterWrapper.add( new FilterWrapper( this ) );
    }
    
    public void setFewFilters(){
        lstFilterWrapper = new list<FilterWrapper>();
        lstFilterWrapper.add( new FilterWrapper( this ) );
    }
    
    public void searchProduct2(){
        
        selectedPriceBookEntries = new list<Id>();
        lstMatchedProducts = new list<ProductsWrapper>();
        this.errorMsg = '';
        String queryWhereClause = '';
        list<String> product2Filters = new list<String>();
        list<String> priceBook2Filters = new list<String>();
        list<String> priceBookEntryFilters = new list<String>();
        
        for( FilterWrapper fieldWrapObj : lstFilterWrapper ){
            if( String.isNotBlank( fieldWrapObj.filterByField ) && String.isNotBlank( fieldWrapObj.filterByOperator ) ){
                String condition = fieldWrapObj.buildSOQLClause();
                
                if( String.isNotBlank( condition ) ){
                    if( fieldWrapObj.sObjType.equalsIgnoreCase('Product2') ){
                        product2Filters.add( condition ); 
                    }else if( fieldWrapObj.sObjType.equalsIgnoreCase('PriceBook2') ){
                        priceBook2Filters.add( condition );
                    }else if( fieldWrapObj.sObjType.equalsIgnoreCase('PriceBookEntry') ){
                        priceBookEntryFilters.add( condition );
                    }
                }
            }
        }
        
        if( !priceBookEntryFilters.isEmpty() ){
            queryWhereClause = ' '+String.join( priceBookEntryFilters, ' AND ' );
        }
        
        if( !product2Filters.isEmpty() || !priceBook2Filters.isEmpty() ){
            String priceBookFilters = '';
            if( !priceBook2Filters.isEmpty() ){
                priceBookFilters += ' '+String.join( priceBook2Filters, ' AND ' );
            }
            if( !product2Filters.isEmpty() ){
                priceBookFilters += String.isNotBlank( priceBookFilters ) ? ' AND  '+String.join( product2Filters , ' AND ' ) : String.join( product2Filters , ' AND ' );
            }
            
            if( String.isNotBlank ( priceBookFilters ) ){
                queryWhereClause += String.isNotBlank( queryWhereClause ) ? ' AND '+priceBookFilters : priceBookFilters;
            }
        }
        
        if( String.isNotBlank( queryWhereClause ) ){
            queryWhereClause = ' WHERE '+queryWhereClause +' AND Pricebook2Id=\''+ opportunityObj.PriceBook2Id +'\' ';
        }else{
            queryWhereClause += ' WHERE Pricebook2Id=\''+ opportunityObj.PriceBook2Id +'\' ';
        } 
        
        this.con = null;
	    if( String.isNotBlank( keyworkSearchText ) ){
        	keyworkSearchText = String.escapeSingleQuotes( keyworkSearchText );
        	String searchquery= 'FIND \''+keyworkSearchText+'*\' IN ALL FIELDS RETURNING PRODUCT2(Id) ';
        	List<List<SObject>>searchList = search.query( searchquery );
        	set<Id> product2sId = new set<Id>();
        	for( Product2 product :  (list<Product2>)searchList[0]){
        		product2sId.add( product.Id );
        	}
        	
        	if( product2sId.size() > 0 ){
        		productSearchQuery = ' SELECT Id, Product2.CanUseQuantitySchedule, Product2.CanUseRevenueSchedule, Product2.Name, Product2.ProductCode, Product2.Family, Product2.Description, Product2Id, UnitPrice, Product2.Pricing_Method__c, Product2.Objective__c '
        					 +' FROM PriceBookEntry ' + ( String.isNotBlank( queryWhereClause ) ? queryWhereClause + ' AND Product2Id in:product2sId ' : ' WHERE Product2Id in:product2sId ' ) ;
        
	        	this.con = new ApexPages.StandardSetController(Database.getQueryLocator( productSearchQuery + ' Order By '+sortByField+' '+sortByOrder + (sortByOrder == 'asc' ? ' NULLS FIRST ' : ' NULLS LAST ') ));
	        
        	}else{
        		this.con = new ApexPages.StandardSetController( new list<PriceBookEntry>() );
	        }
	        
        }else{
        	productSearchQuery = ' SELECT Id, Product2.CanUseQuantitySchedule, Product2.CanUseRevenueSchedule, Product2.Name, Product2.ProductCode, Product2.Family, Product2.Description, Product2Id, UnitPrice, Product2.Pricing_Method__c, Product2.Objective__c '
        					 +' FROM PriceBookEntry ' + ( String.isNotBlank( queryWhereClause ) ? queryWhereClause : '' ) ;
        
	        this.con = new ApexPages.StandardSetController(Database.getQueryLocator( productSearchQuery + ' Order By '+sortByField+' '+sortByOrder + (sortByOrder == 'asc' ? ' NULLS FIRST ' : ' NULLS LAST ') ));
	        
        }
        
        
        System.debug('----> queryWhereClause '+ queryWhereClause );
        this.con.setPageSize( PAGE_SIZE );
        
        populateProducts();
    }
    
    public void sortProducts(){
        this.con = null;
        this.con = new ApexPages.StandardSetController(Database.getQueryLocator( productSearchQuery + ' Order By '+sortByField+' '+ sortByOrder + (sortByOrder == 'asc' ? ' NULLS FIRST ' : ' NULLS LAST ') ));
        this.con.setPageSize( PAGE_SIZE );
        
		populateProducts();
    }
    
    public Class ProductsWrapper{
        public Boolean isSelected{get{ return isSelected != null ? isSelected : false; }set;}
        public PriceBookEntry pbeObj{get;set;}
        
        public ProductsWrapper( PriceBookEntry pbeObj, Boolean isSelected ){
            this.isSelected = isSelected;
            this.pbeObj = pbeObj;
        }
    }
    
    
    set<Id> alreadySelectedProducts = new set<Id>();
    public void createOpportunityLineItems(){
    	errorMsg = ''; 
        collectSelectedPriceBookEntries();
        
        //alreadySelectedProducts.addAll( selectedPriceBookEntries );
        if( selectedPriceBookEntries.size() == 0 ){
        	errorMsg = '<b>Error:</b> Please select at least one Product.';
        	return;
        }
        
        //System.debug('---- > selectedPriceBookEntries : '+selectedPriceBookEntries.size() +'\t values: '+selectedPriceBookEntries);
        if( selectedPriceBookEntries.size() > 0 ){
            for( PriceBookEntry pbeObj : [SELECT Id, Product2.Name, Product2.ProductCode, Product2.Family, Product2.Description, Product2Id, UnitPrice, 
            								Product2.Pricing_Method__c, Product2.Objective__c  
                                            FROM PriceBookEntry 
                                            WHERE Id in:selectedPriceBookEntries order By Product2.Name]){
                lstOLIs.add( new OpportunityLineItemWrapper( pbeObj, opportunityObj ) );                                   
            }
        }
        
        selectedPriceBookEntries = new list<Id>();
        for( ProductsWrapper obj : lstMatchedProducts ) {
            obj.isSelected = false;
        }
        
    }
    
    public String errorMsg{get;set;}
    public void saveAndFlight(){
    	errorMsg = '';
    	if( validateOLIs() ){
    		
    		list<OpportunityLineItem> olisToInsert = new list<OpportunityLineItem>();
    		for( OpportunityLineItemWrapper oliWrap : lstOLIs ){
    			//oliWrap.oliObj.TotalPrice = null;
    			//oliWrap.totalPrice = oliWrap.oliObj.TotalPrice;
    			//olisToInsert.add( createOLIWithoutTotalPrice( oliWrap.oliObj ) );
    			olisToInsert.add( oliWrap.oliObj );
    		}
    		
    		if( !olisToInsert.isEmpty() ){
    			try{
	    			upsert olisToInsert;
	    			Integer i = 0;
	    			for( OpportunityLineItemWrapper oliWrap : lstOLIs ){
	    				//oliWrap.oliObj.Total_Price__c = oliWrap.oliObj.Total_Price__c = oliWrap.totalPrice;
	    				
		    			oliWrap.oliObj.Id = olisToInsert.get(i).Id;
		    			i++;
		    		}
    			}catch( Exception e ){
    				errorMsg = e.getMessage();
    				return;
    			}
    		}
    		
    		for( OpportunityLineItemWrapper oliWrap : lstOLIs ){
    			//olisToInsert.add( oliWrap.oliObj );
    			//oliWrap.oliObj.TotalPrice = oliWrap.totalPrice;
    			oliWrap.hasRevenueError = false;
    			oliWrap.oliSchedules.clear();
    			oliWrap.oliSchedules.addAll( createOLISchedules( oliWrap.oliObj ) ); 
    		}
    		
    		showSaveAndDone = true;
        	showSearchPanel = false;
    	}
    }
    
    /*private OpportunityLineItem createOLIWithoutTotalPrice( OpportunityLineItem oli ){
    	OpportunityLineItem newOLI = new OpportunityLineItem();
    	newOLI.Id = oli.Id;
    	if( newOLI.Id == null ){
	    	newOLI.OpportunityId = oli.OpportunityId;
	    	newOLI.PricebookEntryId = oli.PricebookEntryId;
		}  
    
    	newOLI.Quantity = oli.Quantity;
    	newOLI.Per_Unit_Price__c = oli.Per_Unit_Price__c;
        	
    	
    	newOLI.Pricing_Method__c = oli.Pricing_Method__c;
    	newOLI.ServiceDate = oli.ServiceDate;
    	newOLI.Campaign_End_Date__c = oli.Campaign_End_Date__c;
    	newOLI.Objective__c = oli.Objective__c;
    	newOLI.Position__c = oli.Position__c;
    	newOLI.Dimensions__c = oli.Dimensions__c;
    	newOLI.Tier__c = oli.Tier__c;
    	newOLI.Description = oli.Description;
    	
    	//newOLI.Id = oli.Id;
    	//newOLI.Id = oli.Id;
    	return newOLI;
	}*/
    
    public void resetProductFlight(){
    	if( productIndexToDelete != null && productIndexToDelete < lstOLIs.size() ){
			OpportunityLineItemWrapper oliWrap = lstOLIs.get( productIndexToDelete );
    		Boolean isValid = true;
    		
    		if( oliWrap.oliObj.Total_Price__c == null && !showSaveAndDone ){
    			oliWrap.oliObj.Total_Price__c.addError('You must enter a value.');
    			isValid = false;
    		}
    		if( oliWrap.oliObj.Quantity == null ){
    			oliWrap.oliObj.Quantity.addError('You must enter a value.');
    			isValid = false;
    		}else if( oliWrap.oliObj.Quantity == 0 ){
    			oliWrap.oliObj.Quantity.addError('Quantity must be nonzero.');
    			isValid = false;
    		}else if( oliWrap.oliObj.Quantity < 0 ) {
    			oliWrap.oliObj.Quantity.addError('Quantity must be greater than zero.');
    			isValid = false;
    		}/*else if( (oliWrap.oliObj.Quantity - Integer.valueOf( oliWrap.oliObj.Quantity ) ) > 0 ){
    			String message = String.isNotBlank (oliWrap.oliObj.Pricing_Method__c) && ( oliWrap.oliObj.Pricing_Method__c == 'CPCV' || oliWrap.oliObj.Pricing_Method__c == 'CPC' ) ? 'Clicks must an Integer number.' : 'Impressions must an Integer number.';
    			oliWrap.oliObj.Quantity.addError( message );
    			isValid = false;
    		}*/
    		if( oliWrap.oliObj.Per_Unit_Price__c == null ){
    			oliWrap.oliObj.Per_Unit_Price__c.addError('You must enter a value.');
    			isValid = false;
    		}
    		if( oliWrap.oliObj.Pricing_Method__c == null ){
    			oliWrap.oliObj.Pricing_Method__c.addError('You must select a value.');
    			isValid = false;
    		}
    		if( oliWrap.oliObj.ServiceDate == null ){
    			oliWrap.oliObj.ServiceDate.addError('You must enter a value.');
    			isValid = false;
    		}
    		if( oliWrap.oliObj.Campaign_End_Date__c == null ){ 
    			oliWrap.oliObj.Campaign_End_Date__c.addError('You must enter a value.');
    			isValid = false;
    		} 
    		  
    		if( oliWrap.oliObj.ServiceDate != null && oliWrap.oliObj.Campaign_End_Date__c != null && 
								oliWrap.oliObj.ServiceDate > oliWrap.oliObj.Campaign_End_Date__c ){
    			oliWrap.oliObj.Campaign_End_Date__c.addError('Campaign End Date must be greater than Campaign Start Date.');
    			oliWrap.oliObj.ServiceDate.addError('Campaign Start Date must be less than Campaign End Date.');
    			isValid = false;
    		}
    		
    		if( !isValid ) return;
    		 
    		oliWrap.hasRevenueError = false;
    		oliWrap.oliSchedules.clear();
			oliWrap.oliSchedules.addAll( createOLISchedules( oliWrap.oliObj ) ); 
			productIndexToDelete = null;
    	}
    }
    
    public PageReference saveAndDone(){
    	if( validateOLIs() ){
    		Boolean isValid = true;
    		for( OpportunityLineItemWrapper oliWrap : lstOLIs ){
    			//olisToInsert.add( oliWrap.oliObj );
				oliWrap.hasRevenueError = false;
				Decimal totalScheduledRevenue = 0 ;
				Boolean missingRevenue = false;
    			for( OpportunityLineItemSchedule oliSchedule : oliWrap.oliSchedules ){
    				if( oliSchedule.Revenue == null ){
    					oliSchedule.Revenue.addError('You must enter a value.');
    					isValid = false;
    					missingRevenue = true;
    				}else{
    					totalScheduledRevenue += oliSchedule.Revenue;
    				}
    			}
    			
    			if( missingRevenue ) continue;
    			
    			if( oliWrap.oliSchedules.size() > 1 ){
    				totalScheduledRevenue = totalScheduledRevenue - oliWrap.oliSchedules.get( oliWrap.oliSchedules.size() - 1 ).Revenue;
    				if( totalScheduledRevenue  > oliWrap.oliObj.Total_Price__c ){
	 		   			oliWrap.hasRevenueError = true;
	 		   			oliWrap.oliSchedules.get( oliWrap.oliSchedules.size() - 1 ).Revenue = oliWrap.oliObj.Total_Price__c - totalScheduledRevenue; 
	    				isValid = false;
	    			}else{
	    				oliWrap.oliSchedules.get( oliWrap.oliSchedules.size() - 1 ).Revenue = oliWrap.oliObj.Total_Price__c - totalScheduledRevenue; 
	    			}
    			}
    			/*if( oliWrap.oliObj.Total_Price__c != totalScheduledRevenue ){
    				oliWrap.oliObj.Quantity.addError('Total of Scheduled Quantity must equal to Product\'s Quantity.');
    				isValid = false;
    			}*/
    		}
    		
    		if( !isValid ) return null;
    		//return null;
			list<OpportunityLineItem> olisToInsert = new list<OpportunityLineItem>();
    		list<OpportunityLineItemSchedule> oliSchedulesToUpsert = new list<OpportunityLineItemSchedule>();
    		
    		for( OpportunityLineItemWrapper oliWrap : lstOLIs ){
    			olisToInsert.add( oliWrap.oliObj );
    			oliSchedulesToUpsert.addAll( oliWrap.oliSchedules );
    		}
    		
    		if( !olisToInsert.isEmpty() ){
    			upsert olisToInsert;
    		}
    		
    		if( !oliSchedulesToUpsert.isEmpty() ){
    			upsert oliSchedulesToUpsert;
    		}
    		
    		return new PageReference('/'+opportunityObj.Id).setRedirect( true );
    	}
    	return null;
    }
    
    private list<OpportunityLineItemSchedule> createOLISchedules( OpportunityLineItem oliObj ){
    	
    	list<OpportunityLineItemSchedule> newOLISchedules = new list<OpportunityLineItemSchedule>();
    	Long numberOfMonths = oliObj.ServiceDate.monthsBetween( oliObj.Campaign_End_Date__c );
    	numberOfMonths = numberOfMonths == 0 ? 1 : numberOfMonths+1;
    	Integer index = 0;
    	Decimal quantityScheduled = 0.00;
    	Integer totalRevenue = 0;
    	do{
    		OpportunityLineItemSchedule oliSchedule = new OpportunityLineItemSchedule();
    		oliSchedule.OpportunityLineItemId = oliObj.Id;
    		oliSchedule.Quantity = Integer.valueOf( oliObj.Quantity / (numberOfMonths) );
    		quantityScheduled += oliSchedule.Quantity;
    		oliSchedule.Type = 'Both';
    		oliSchedule.ScheduleDate = oliObj.ServiceDate.addMonths( index );
    		oliSchedule.Revenue = Math.floor( oliObj.Pricing_Method__c == 'CPM' || oliObj.Pricing_Method__c == 'vCPM' ? ( oliSchedule.Quantity * oliObj.Per_Unit_Price__c ) / 1000 : ( oliSchedule.Quantity * oliObj.Per_Unit_Price__c ) );
    		totalRevenue += Integer.valueOf( oliSchedule.Revenue );
    		newOLISchedules.add( oliSchedule );
    		index++;
    	}while( index < numberOfMonths );
    	
    	//if( numberOfMonths > 1 ){
    		
    		Decimal remainder = oliObj.Quantity - quantityScheduled;
    		if( remainder > 0 ){
    			newOLISchedules.get( newOLISchedules.size() - 1 ).Quantity += remainder;
    			//newOLISchedules.get( newOLISchedules.size() - 1 ).Revenue = Math.round( oliObj.Pricing_Method__c == 'CPM' || oliObj.Pricing_Method__c == 'vCPM' ? ( newOLISchedules.get( newOLISchedules.size() - 1 ).Quantity * oliObj.Per_Unit_Price__c ) / 1000 : ( newOLISchedules.get( newOLISchedules.size() - 1 ).Quantity * oliObj.Per_Unit_Price__c ) ); //newOLISchedules.get( newOLISchedules.size() - 1 ).Quantity * oliObj.Per_Unit_Price__c;
    		}
    		
    		Decimal revenueRemainder = oliObj.Total_Price__c - totalRevenue;
    		if( revenueRemainder > 0 ){
    			//newOLISchedules.get( newOLISchedules.size() - 1 ).Quantity += remainder;
    			newOLISchedules.get( newOLISchedules.size() - 1 ).Revenue += revenueRemainder; //Math.round( oliObj.Pricing_Method__c == 'CPM' || oliObj.Pricing_Method__c == 'vCPM' ? ( newOLISchedules.get( newOLISchedules.size() - 1 ).Quantity * oliObj.Per_Unit_Price__c ) / 1000 : ( newOLISchedules.get( newOLISchedules.size() - 1 ).Quantity * oliObj.Per_Unit_Price__c ) ); //newOLISchedules.get( newOLISchedules.size() - 1 ).Quantity * oliObj.Per_Unit_Price__c;
    		}
    		if( totalRevenue - oliObj.Total_Price__c > 0 ){
    			newOLISchedules.get( newOLISchedules.size() - 1 ).Revenue -= (totalRevenue - oliObj.Total_Price__c);
    		}
    		
    		
    	//}
    	
    	return newOLISchedules;
    }
    
    private Boolean validateOLIs(){
    	
    	Boolean isValid = true;
    	
    	for( OpportunityLineItemWrapper oliWrap : lstOLIs ){
    		if( oliWrap.oliObj.Total_Price__c == null && !showSaveAndDone ){
    			oliWrap.oliObj.Total_Price__c.addError('You must enter a value.');
    			isValid = false;
    		}else if( oliWrap.oliObj.Total_Price__c < 0 ) {
    			oliWrap.oliObj.Total_Price__c.addError('Total Price must be greater than zero.');
    			isValid = false;
    		}
    		
    		if( oliWrap.oliObj.Per_Unit_Price__c == null ){
    			oliWrap.oliObj.Per_Unit_Price__c.addError('You must enter a value.');
    			isValid = false;
    		}else if( oliWrap.oliObj.Per_Unit_Price__c < 0 ) {
    			oliWrap.oliObj.Per_Unit_Price__c.addError('Unit Price must be greater than zero.');
    			isValid = false;
    		}
    		
    		if( oliWrap.oliObj.Quantity == null ){
    			oliWrap.oliObj.Quantity.addError('You must enter a value.');
    			isValid = false;
    		}else if( oliWrap.oliObj.Quantity == 0 ){
    			oliWrap.oliObj.Quantity.addError('Quantity must be nonzero.');
    			isValid = false;
    		}else if( oliWrap.oliObj.Quantity < 0 ) {
    			oliWrap.oliObj.Quantity.addError('Quantity must be greater than zero.');
    			isValid = false;
    		}
    		
    		if( oliWrap.oliObj.Pricing_Method__c == null ){
    			oliWrap.oliObj.Pricing_Method__c.addError('You must select a value.');
    			isValid = false;
    		}
    		if( oliWrap.oliObj.ServiceDate == null ){
    			oliWrap.oliObj.ServiceDate.addError('You must enter a value.');
    			isValid = false;
    		}
    		if( oliWrap.oliObj.Campaign_End_Date__c == null ){
    			oliWrap.oliObj.Campaign_End_Date__c.addError('You must enter a value.');
    			isValid = false;
    		}
    		
    		if( oliWrap.oliObj.ServiceDate != null && oliWrap.oliObj.Campaign_End_Date__c != null && 
								oliWrap.oliObj.ServiceDate > oliWrap.oliObj.Campaign_End_Date__c ){
    			oliWrap.oliObj.Campaign_End_Date__c.addError('Campaign End Date must be greater than Campaign Start Date.');
    			oliWrap.oliObj.ServiceDate.addError('Campaign Start Date must be less than Campaign End Date.');
    			isValid = false;
    		}
    	}
    	return isValid;
    }
    
    public class OpportunityLineItemWrapper{
    	public String product2Id{get;set;}
    	public String product2Name{get;set;}
    	public Boolean hasRevenueError{get;set;}
    	
    	public OpportunityLineItem oliObj{get;set;}
    	public list<OpportunityLineItemSchedule> oliSchedules{get;set;}
    	
    	public OpportunityLineItemWrapper( PriceBookEntry pbeObj, Opportunity oppObj ){
    		this.oliObj = new OpportunityLineItem();
	        //oliObj.TotalPrice = pbeObj.Product2Id;
	        this.oliObj.UnitPrice = pbeObj.UnitPrice; 
	        this.oliObj.Per_Unit_Price__c = pbeObj.UnitPrice;
	        this.oliObj.PricebookEntryId = pbeObj.Id;
	        this.oliObj.OpportunityId = oppObj.Id;
	        this.oliObj.ServiceDate = oppObj.IO_Campaign_Start_Date__c;
	        this.oliObj.Campaign_End_Date__c = oppObj.IO_Campaign_End_Date__c;
	        this.oliObj.Pricing_Method__c = pbeObj.Product2.Pricing_Method__c;
	        this.oliObj.Objective__c = pbeObj.Product2.Objective__c;
	        //this.oliObj.Pricing_Method__c = pbeObj.Product2.
	        
	        this.product2Id = pbeObj.Product2Id;
	        this.product2Name = pbeObj.product2.Name;
	        
	        hasRevenueError = false;
	        oliSchedules = new list<OpportunityLineItemSchedule>();
    	}
    }
    
    public PageReference removeSelectedProduct(){
    	if( productIndexToDelete != null ){
    		OpportunityLineItemWrapper oliWrapObj = lstOLIs.get( productIndexToDelete );
    		Id oliID = oliWrapObj.oliObj.Id;
    		if( oliID != null ){
	    		list<OpportunityLineItemSchedule> oliSchedules = new list<OpportunityLineItemSchedule>( [SELECT Id FROM OpportunityLineItemSchedule WHERE OpportunityLineItemId=:oliID ] );
    			if( !oliSchedules.isEmpty() ){
    				delete oliSchedules;
    			}
    			delete new OpportunityLineItem( Id=oliID);
    		}		
	    	lstOLIs.remove( productIndexToDelete );
    	}
    	
    	if( lstOLIs.size() == 0 ){
    		return new PageReference('/apex/AddOpportunityProducts?id='+opportunityObj.Id).setRedirect(true);
    	}
    	return null;
    }
    
    public PageReference removeAllSelectedProduct(){
    	
    	list<OpportunityLineItem> olisToDelete = new list<OpportunityLineItem>();
    	list<OpportunityLineItemSchedule> lstoliSchedules = new list<OpportunityLineItemSchedule>();
    	
    	for( OpportunityLineItemWrapper oliWrapObj : lstOLIs ){
    		Id oliID = oliWrapObj.oliObj.Id;
    		if( oliID != null ){
	    		list<OpportunityLineItemSchedule> oliSchedules = new list<OpportunityLineItemSchedule>( [SELECT Id FROM OpportunityLineItemSchedule WHERE OpportunityLineItemId=:oliID ] );
    			if( !oliSchedules.isEmpty() ){
    				lstoliSchedules.addAll( oliSchedules );
				}
    			
    			olisToDelete.add( new OpportunityLineItem( Id=oliID) );
    		}		
    	}
    	
    	if( !lstoliSchedules.isEmpty() ){
    		delete lstoliSchedules;
    	}
    	if( !olisToDelete.isEmpty() ){
    		delete olisToDelete;
    	}
    	
    	lstOLIs.clear();
    	
    	//if( showSaveAndDone ){
    		return new PageReference('/apex/AddOpportunityProducts?id='+opportunityObj.Id).setRedirect(true);
    	//}
    	return null;
    }
     
    public PageReference cancelAddProduct(){
        return new PageReference( '/'+opportunityObj.Id ); 
    }
    //o.Description, o.CreatedDate, o.CreatedById, o.Campaign_End_Date__c From OpportunityLineItem o
    
    public class FilterWrapper{
        public String filterByField{get;set;}
        public String filterByOperator{get;set;}
        public String filterByValue{get;set;} 
        
        private AddOpportunityProductsController parentObj{get;set;}
        
        public FilterWrapper( AddOpportunityProductsController parentObj ){
        	this.parentObj = parentObj;
        }
        
        public String sObjType{get{
            return filterByField.subStringBefore('.');
        }set;}
        public String fieldName{get{
            return filterByField.subStringAfter('.');
        }set;}
        
        private Map<String, Schema.SobjectField> product2FieldMap = Schema.getGlobalDescribe().get('Product2').getDescribe().fields.getMap();
        private Map<String, Schema.SobjectField> priceBookEntryFieldMap = Schema.getGlobalDescribe().get('PriceBookEntry').getDescribe().fields.getMap();
        private Map<String, Schema.SobjectField> PriceBook2FieldMap = Schema.getGlobalDescribe().get('PriceBook2').getDescribe().fields.getMap();
        
        
        public list<SelectOption> FilterOperatorOptions{get{
            return new list<SelectOption>{ new SelectOption( '', '--None--' ), new SelectOption( '', '--None--' ), new SelectOption( 'e', 'equals' ),
                                            new SelectOption( 'n', 'not equal to' ), new SelectOption( 's', 'starts with' ), new SelectOption( 'c', 'contains' ),
                                            new SelectOption( 'k', 'does not contain' ), new SelectOption( 'l', 'less than' ), new SelectOption( 'g', 'greater than' ),
                                            new SelectOption( 'm', 'less or equal' ), new SelectOption( 'h', 'greater or equal' ), new SelectOption( 'u', 'includes' ),
                                            new SelectOption( 'x', 'excludes' ), new SelectOption( 'w', 'within' )};
            }
        }
        
        public String buildSOQLClause(){
            System.debug( '----> sObjType : '+sObjType );
            Schema.DisplayType fielddataType = sObjType.equalsIgnoreCase('product2') ?  product2FieldMap.get( fieldName ).getDescribe().getType() : ( sObjType.equalsIgnoreCase('pricebook2') ?  pricebook2FieldMap.get( fieldName ).getDescribe().getType() : priceBookEntryFieldMap.get( fieldName ).getDescribe().getType() );
            if( ( fielddataType == Schema.Displaytype.MultiPickList || fielddataType == Schema.Displaytype.PickList ) && filterByValue.contains(',') ){
                return buildMultipleSOQLClause();
            }else{
                return buildSingleSOQLClause();
            }
        }
        
        public String buildSingleSOQLClause( ){
            
            String sobjectType = sObjType;
            String sobjectField = fieldName;
            filterByValue = String.escapeSingleQuotes( filterByValue );
            Schema.DisplayType fielddataType = sobjectType.equalsIgnoreCase('product2') ?  product2FieldMap.get( sobjectField ).getDescribe().getType() : ( sobjectType.equalsIgnoreCase('pricebook2') ?  pricebook2FieldMap.get( sobjectField ).getDescribe().getType() : priceBookEntryFieldMap.get( sobjectField ).getDescribe().getType() );
            
            if( sobjectType.equalsIgnoreCase('PriceBook2') ) sobjectField = 'PriceBook2.'+sobjectField;
            if( sobjectType.equalsIgnoreCase('Product2') ) sobjectField = 'Product2.'+sobjectField;
            
            if ( fielddataType == Schema.Displaytype.Email || fielddataType == Schema.Displaytype.ID ||
                    fielddataType == Schema.Displaytype.MultiPickList || fielddataType == Schema.Displaytype.Phone ||
                    fielddataType == Schema.Displaytype.PickList || fielddataType == Schema.Displaytype.Reference ||
                    fielddataType == Schema.Displaytype.String || fielddataType == Schema.Displaytype.TextArea ||
                    fielddataType == Schema.Displaytype.URL 
               ){
                if ( filterByOperator == 'c' ){
                    if( filterByValue.contains( ',') ){
                        list<String> orCondictions = new list<String>();
                        for(String val : filterByValue.split(',') ){
                            val = val.trim();
                            if( String.isNotBlank( val ) ){
                                orCondictions.add( ' '+sobjectField+' LIKE \'%' + val + '%\' ' );
                            }
                        }
                        if( !orCondictions.isEmpty() ){
                            return '( ' +String.join( orCondictions, ' OR ' ) +' ) ';
                        }
                        
                    }else{
                        return ' '+sobjectField+' LIKE \'%' + filterByValue + '%\' ';
                    }
                }else if ( filterByOperator == 'k' ) {
                    if( filterByValue.contains( ',') ){
                        list<String> orCondictions = new list<String>();
                        for(String val : filterByValue.split(',') ){
                            val = val.trim();
                            if( String.isNotBlank( val ) ){
                                orCondictions.add( ' ( NOT '+sobjectField +' LIKE \'%' + val + '%\' ) ' );
                            }
                        }
                        if( !orCondictions.isEmpty() ){
                            return ' ( ' +String.join( orCondictions, ' AND ' ) +' ) ';
                        }
                    }else{
                        return ' ( NOT '+sobjectField +' LIKE \'%' + filterByValue + '%\' ) ';
                    }
                }else if ( filterByOperator == 's' ) {
                    if( filterByValue.contains( ',') ){
                        list<String> orCondictions = new list<String>();
                        for(String val : filterByValue.split(',') ){
                            val = val.trim();
                            if( String.isNotBlank( val ) ){
                                orCondictions.add(  ' '+sobjectField +' LIKE \'' + val + '%\' ' );
                            }
                        }
                        if( !orCondictions.isEmpty() ){
                            return ' ( ' +String.join( orCondictions, ' OR ' ) +' ) ';
                        }
                        
                    }else{
                        return  ' '+sobjectField +' LIKE \'' + filterByValue + '%\' ';
                    }
                }else if( filterByOperator == 'e' || filterByOperator == 'n' ) {
                    return ' '+sobjectField +' '+( filterByOperator == 'e' ? ' = ' : ' != ' ) +' \'' + filterByValue + '\' ';
                }else if( filterByOperator == 'g' || filterByOperator == 'h' ) {
                    return ' '+sobjectField +' '+( filterByOperator == 'g' ? ' > ' : ' >= ' ) +' \'' + filterByValue + '\' ';
                }else if( filterByOperator == 'l' || filterByOperator == 'm' ) {
                    return ' '+sobjectField +' '+( filterByOperator == 'g' ? ' < ' : ' <= ' ) +' \'' + filterByValue + '\' ';
                }
            }else {                                                
                if( fielddataType == Schema.Displaytype.DATE || fielddataType == Schema.Displaytype.DateTime){
                    if( String.isNotBlank( filterByValue ) ){
                        //String[] dts = filterByValue.split('/');
                            String dateVal = '';
                            if( fielddataType == Schema.Displaytype.DATE ){
                            	if( validateDate( filterByValue, 'date' ) ){
	                                Date myDate = date.parse( filterByValue );
    	                        	dateVal = string.valueof(myDate) ;
                            	}else{
                            		parentObj.errorMsg += String.isNotBlank( parentObj.errorMsg ) ? '<br/>Error:Invalid date (Valid date format '+System.today().format()+' or '+System.now().format()+').' : 'Error:Invalid date (Valid date format '+System.today().format()+' or '+System.now().format()+').';
                            		return '';
                            	}
		                    }else if( fielddataType == Schema.Displaytype.DateTime){
		                    	
		                    	//String dateTimeRegex = '/^(((0[13578]|1[02])[\/\.-](0[1-9]|[12]\d|3[01])[\/\.-]((19|[2-9]\d)\d{2})\s(0[0-9]|1[0-2]):(0[0-9]|[1-59]\d):(0[0-9]|[1-59]\d)\s(AM|am|PM|pm))|((0[13456789]|1[012])[\/\.-](0[1-9]|[12]\d|30)[\/\.-]((19|[2-9]\d)\d{2})\s(0[0-9]|1[0-2]):(0[0-9]|[1-59]\d):(0[0-9]|[1-59]\d)\s(AM|am|PM|pm))|((02)[\/\.-](0[1-9]|1\d|2[0-8])[\/\.-]((19|[2-9]\d)\d{2})\s(0[0-9]|1[0-2]):(0[0-9]|[1-59]\d):(0[0-9]|[1-59]\d)\s(AM|am|PM|pm))|((02)[\/\.-](29)[\/\.-]((1[6-9]|[2-9]\d)(0[48]|[2468][048]|[13579][26])|((16|[2468][048]|[3579][26])00))\s(0[0-9]|1[0-2]):(0[0-9]|[1-59]\d):(0[0-9]|[1-59]\d)\s(AM|am|PM|pm)))$/g';
		                    	
		                    	if( validateDate( filterByValue, 'datetime' ) ){
	                                Datetime dt = datetime.parse( filterByValue );
    	                        	dateVal = dt.format('yyyy-MM-dd\'T\'hh:mm:ss\'Z\'');
                            	}else{
                            		parentObj.errorMsg += String.isNotBlank( parentObj.errorMsg ) ? '<br/>Error:Invalid date (Valid date format '+System.today().format()+' or '+System.now().format()+').' : 'Error:Invalid date (Valid date format '+System.today().format()+' or '+System.now().format()+').';
                            		return '';
                            	}
                            }
                            
                            if( filterByOperator == 'e' || filterByOperator == 'n' ) {
                                return ' '+sobjectField +' '+( filterByOperator == 'e' ? ' = ' : ' != ' ) +' ' + dateVal + ' ';
                            }else if( filterByOperator == 'g' || filterByOperator == 'h' ) {
                                return ' '+sobjectField +' '+( filterByOperator == 'g' ? ' > ' : ' >= ' ) +' ' + dateVal + ' ';
                            }else if( filterByOperator == 'l' || filterByOperator == 'm' ) {
                                return ' '+sobjectField +' '+( filterByOperator == 'g' ? ' < ' : ' <= ' ) +' ' + dateVal + ' ';
                            }else{
	                            return '';
    						}
                       /*}else{
                            return '';
                        }*/
                    }
                }else if( fielddataType == Schema.Displaytype.CURRENCY || fielddataType == Schema.Displaytype.Double ){
                    if( String.isNotBlank( filterByValue ) && filterByValue.isNumeric() ){
                        if( filterByOperator == 'e' || filterByOperator == 'n' ) {
                            return ' '+sobjectField +' '+( filterByOperator == 'e' ? ' = ' : ' != ' ) +filterByValue+ ' ';
                        }else if( filterByOperator == 'g' || filterByOperator == 'h' ) {
                            return ' '+sobjectField +' '+( filterByOperator == 'g' ? ' > ' : ' >= ' ) + filterByValue + ' ';
                        }else if( filterByOperator == 'l' || filterByOperator == 'm' ) {
                            return ' '+sobjectField +' '+( filterByOperator == 'g' ? ' < ' : ' <= ' ) + filterByValue + ' ';
                        }
                    }else{
                        return '';
                    } 
                }else if( fielddataType == Schema.Displaytype.Boolean ){
                    if( filterByValue == '0' || filterByValue == 'false' || filterByValue == '' ){
                        return ' '+sobjectField +' '+( filterByOperator == 'e' ? ' = ' : ' != ' ) +' false ';
                    }else if( filterByValue == '1' || filterByValue == 'true'  ){
                        return ' '+sobjectField +' '+( filterByOperator == 'e' ? ' = ' : ' != ' ) +' true ';
                    }else{
                		parentObj.errorMsg += String.isNotBlank( parentObj.errorMsg ) ? '<br/>Error:Invalid Boolean ( Use "False" or "True" )' : 'Error:Invalid Boolean ( Use "False" or "True" )';
                		return '';
                	}
                }else{
                    return '';
                }
            }
            return '';
        }
        
        public String buildMultipleSOQLClause(){
            
            String sobjectType = sObjType;
            String sobjectField = fieldName;
            filterByValue = String.escapeSingleQuotes( filterByValue );
            Schema.DisplayType fielddataType = sobjectType.equalsIgnoreCase('product2') ?  product2FieldMap.get( sobjectField ).getDescribe().getType() : ( sobjectType.equalsIgnoreCase('pricebook2') ?  pricebook2FieldMap.get( sobjectField ).getDescribe().getType() : priceBookEntryFieldMap.get( sobjectField ).getDescribe().getType() );
            
            if( sobjectType.equalsIgnoreCase('PriceBook2') ) sobjectField = 'PriceBook2.'+sobjectField;
            if( sobjectType.equalsIgnoreCase('Product2') ) sobjectField = 'Product2.'+sobjectField;
            
            list<String> orCondictions = new list<String>();
            
            if ( filterByOperator == 'c' ){
                for(String val : filterByValue.split(',') ){
                    val = val.trim();
                    if( String.isNotBlank( val ) ){
                        orCondictions.add( ' '+sobjectField+' LIKE \'%' + val + '%\' ' );
                    }
                }
                if( !orCondictions.isEmpty() ){
                    return '( ' +String.join( orCondictions, ' OR ' ) +' ) ';
                }
            }else if ( filterByOperator == 'k' ) {
                for(String val : filterByValue.split(',') ){
                    val = val.trim();
                    if( String.isNotBlank( val ) ){
                        orCondictions.add( ' ( NOT '+sobjectField +' LIKE \'%' + val + '%\' ) ' );
                    }
                }
                if( !orCondictions.isEmpty() ){
                    return ' ( ' +String.join( orCondictions, ' AND ' ) +' ) ';
                }
            }else if ( filterByOperator == 's' ) {
                for(String val : filterByValue.split(',') ){
                    val = val.trim();
                    if( String.isNotBlank( val ) ){
                        orCondictions.add(  ' '+sobjectField +' LIKE \'' + val + '%\' ' );
                    }
                }
                if( !orCondictions.isEmpty() ){
                    return ' ( ' +String.join( orCondictions, ' OR ' ) +' ) ';
                }
            }
            else if ( filterByOperator == 'u' ) {
                return ' '+sobjectField +' IN ( '+ filterByValue +' ) ';
            }
            else if ( filterByOperator == 'x' ) {
                return ' '+sobjectField +' NOT IN ( '+ filterByValue +' ) ';
            }
                        
            return '';
        }
        
        private Boolean validateDate( String dateString, String fieldType ){
        	String dateRegEx = fieldType == 'date' ? '(0?[1-9]|1[012])/(0?[1-9]|[12][0-9]|3[01])/((19|20)\\d\\d)' : '^(([0]?[1-9]|1[0-2])/([0-2]?[0-9]|3[0-1])/[1-2]\\d{3}) (20|21|22|23|[0-1]?\\d{1}):([0-5]?\\d{1})$';
			Pattern myPattern = Pattern.compile(dateRegEx);
			Matcher myMatcher = myPattern.matcher( dateString );
			 
			if( !myMatcher.matches() ){ 
				return false;
			}
			
			
			return true;
        }
    }
    
    public list<SelectOption> getProductFieldFiltersOptions(){
        return new list<SelectOption>{ new SelectOption( '', '--None--' ),  new SelectOption( 'PriceBook2.Name', 'Price Book Name' ), new SelectOption( 'PriceBook2.IsActive', 'Active (Price Book)' ), new SelectOption( 'Product2.Name', 'Product Name' ),
                                        new SelectOption( 'Product2.ProductCode', 'Product Code' ), new SelectOption( 'Product2.Family', 'Product Family' ), new SelectOption( 'PricebookEntry.UnitPrice', 'Standard Price' ), new SelectOption( 'PricebookEntry.UseStandardPrice', 'Use Standard Price' ),
                                        new SelectOption( 'PricebookEntry.IsActive', 'Active (Price)' ), new SelectOption( 'Product2.Description', 'Product Description' ), //new SelectOption( 'HAS_DEF_QTY_SCHEDULE', 'Has Quantity Schedule' ), //new SelectOption( 'HAS_DEF_REV_SCHEDULE', 'Has Revenue Schedule' ),
                                        new SelectOption( 'PricebookEntry.CreatedDate', 'Created Date' ), new SelectOption( 'PricebookEntry.LastModifiedDate', 'Last Modified Date' ), new SelectOption( 'Product2.CreatedBy.Alias', 'Created By Alias' ),
                                        new SelectOption( 'Product2.LastModifiedBy.Alias', 'Last Update By Alias' ), new SelectOption( 'Product2.IsActive', 'Active (Product)' ), new SelectOption( 'Product2.QuantityScheduleType', 'Quantity Schedule Type' ),
                                        new SelectOption( 'Product2.QuantityInstallmentPeriod', 'Quantity Installment Period' ), new SelectOption( 'Product2.NumberOfQuantityInstallments', 'Number Of Quantity Installments' ), new SelectOption( 'Product2.RevenueScheduleType', 'Revenue Schedule Type' ),
                                        new SelectOption( 'Product2.RevenueInstallmentPeriod', 'Revenue Installment Period' ), new SelectOption( 'Product2.NumberOfRevenueInstallments', 'Number Of Revenue Installments' ), new SelectOption( 'Product2.Provider_Account__c', 'Provider Account' )
                            };  
    }
}