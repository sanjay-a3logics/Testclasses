public with sharing class AccountRelatedOpportunitiesController {
    
    public Account accObj{get;set;}
    
    private static final Integer PAGE_SIZE = 5;
    
    public String sortByOrder{get{
        return String.isNotBlank( sortByOrder ) ? sortByOrder : 'asc';
    }set;}
    public String sortByField{get;set;}
    public String queryStr{get;set;}
    //public List<Opportunity> opportunities {get;set;}
    public ApexPages.StandardController sc{get;set;}
    public String accId{get;set;}
    public AccountRelatedOpportunitiesController( ApexPages.StandardController sc ){
        this.sc = sc;
        accId = this.sc.getId(); 
        sortByField = 'Name';
        sortByOrder = 'asc';
        init();
    }
    
    public void init(){
         
        accObj = [SELECT Id, RecordType.DeveloperName FROM Account WHERE Id=:this.sc.getId() limit 1];
        
        queryStr = 'Select o.StageName, o.Name, o.Id, o.IO_Campaign_Start_Date__c, o.IO_Campaign_End_Date__c, o.CloseDate, o.Amount, o.Agency__c,o.Agency__r.Name, '+
                   ' o.AccountId, o.Account.Name From Opportunity o ';
        queryStr += accObj.RecordType.DeveloperName == 'Agency' ? ' WHERE Agency__c=\''+accObj.Id+'\' AND RecordType.Name=\'Parent\' ' : ' WHERE AccountId=\''+accObj.Id+'\' AND RecordType.Name=\'Parent\' ' ;
        
        queryStr += ' order by '+sortByField+' '+sortByOrder +' '+ (sortByOrder == 'asc' ? ' NULLS FIRST ' : ' NULLS LAST ');
        System.debug( '----> queryStr : '+queryStr);
        this.con = null;
        con = new ApexPages.StandardSetController(Database.getQueryLocator( queryStr ));
        con.setPageSize( PAGE_SIZE );
        //opportunities = getLstOpportunities(); 
    }

    // instantiate the StandardSetController from a query locator
    public ApexPages.StandardSetController con {
        get;set;
    }
    
    //ApexPages.StandardSetController con;
    // returns a list of wrapper objects for the sObjects in the current page set
    public List<Opportunity> getLstOpportunities() {
        List<Opportunity> opportunities = new List<Opportunity>();
        
        for (Opportunity OppObj : (List<Opportunity>)con.getRecords())
            opportunities.add( OppObj);

        return opportunities;
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
         con.first();
     }

     // returns the last page of records
     public void last() {
         con.last();
     }

     // returns the previous page of records
     public void previous() {
         con.previous();
     }

     // returns the next page of records
     public void next() {
         con.next();
     }

     // returns the PageReference of the original page, if known, or the home page.
     public void cancel() {
         con.cancel();
     }
}