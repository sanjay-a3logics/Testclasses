@isTest
public class AccountRelatedOpportunitiesCon_Test
{    public static testMethod void AccRelatedOppTest()
    {  
        List<RecordType> rcList = [select id,name,developerName from RecordType where sobjectType = 'Account' AND (developerName = 'Brand' or developerName = 'Agency')];
        String DevNameBrand = '';
        String DevNameAgency = '';
        for(RecordType rc : rcList)
        {
            if(rc.developerName == 'Brand')
            {
                DevNameBrand = rc.Id;
            }
            else if(rc.developerName == 'Agency')
            {
                DevNameAgency = rc.id;
            }
        }
        
        System.assert(DevNameBrand  != NUll || DevNameBrand  != '');
        System.assert(DevNameAgency  != NUll || DevNameAgency   != '');
        
        Account acc = new Account(Name = 'Test1',recordtypeId = DevNameBrand);
        insert acc;
        System.assertEquals(acc.Name,'Test1');
        Account acc1 = new Account(Name = 'Test2',recordtypeId = DevNameAgency);
        insert acc1;
        System.assertEquals(acc1.Name,'Test2');
        
        String RecTypeNameParent = '';
        String RecTypeNameflight = '';
        List<RecordType> rcListOpp= [select id,name,developerName from RecordType where sobjectType = 'opportunity' AND (Name = 'parent' or Name = 'flight')];
        for(RecordType rc : rcListOpp)
        {
            if(rc.Name == 'parent')
            {
                RecTypeNameParent = rc.Id;
            }
            else if(rc.Name == 'flight')
            {
                RecTypeNameflight = rc.Id;
            }
        }
        System.assert(RecTypeNameflight != NUll || RecTypeNameflight != '');
        System.assert(RecTypeNameparent != NUll || RecTypeNameparent != '');
        
        List<Opportunity> oppList = new List<Opportunity>();
        for(Integer i=0;i<3;i++)
        {
            oppList.add(new Opportunity(Name = 'oppTest0',AccountId=acc.Id,StageName='RFP',CloseDate=Date.today(),recordtypeId=RecTypeNameParent));
            
            oppList.add(new Opportunity(Name = 'oppTest1',AccountId=acc.Id,StageName='Closed Won',CloseDate=Date.today()+1,recordtypeId=RecTypeNameParent));
            
            oppList.add(new Opportunity(Name = 'oppTest2',AccountId=acc.Id,StageName='Prospecting',CloseDate=Date.today()+2,recordtypeId=RecTypeNameParent));
            
            oppList.add(new Opportunity(Name = 'oppTest3',AccountId=acc.Id,StageName='Qualification',CloseDate=Date.today()+3,recordtypeId=RecTypeNameParent));
            
            oppList.add(new Opportunity(Name = 'oppTest4',AccountId=acc.Id,StageName='Proposal',CloseDate=Date.today()+4,recordtypeId=RecTypeNameParent));
            
            oppList.add(new Opportunity(Name = 'oppTest5',AccountId=acc.Id,StageName='Proposal Engaged',CloseDate=Date.today()+5,recordtypeId=RecTypeNameParent));
            
            oppList.add(new Opportunity(Name = 'oppTest6',AccountId=acc.Id,StageName='Running',CloseDate=Date.today()+6,recordtypeId=RecTypeNameParent));
            
            oppList.add(new Opportunity(Name = 'oppTest7',AccountId=acc.Id,StageName='Scale',CloseDate=Date.today()+7,recordtypeId=RecTypeNameParent));
            
            oppList.add(new Opportunity(Name = 'oppTest8',AccountId=acc.Id,StageName='Closed Lost',CloseDate=Date.today()+8,recordtypeId=RecTypeNameParent));

        }
        insert oppList;
        List<Opportunity> listOpp = [select id from opportunity where AccountId =: acc.Id];
        System.assertEquals(listOpp.size(),27);
        
        List<Opportunity> listOpp2 = [select id from opportunity where AccountId =: acc.Id AND recordTypeID =: RecTypeNameParent];
        System.assertEquals(listOpp2.size(),27);
        
        
        List<Opportunity> oppList1 = new List<Opportunity>();
        for(Integer i=0;i<3;i++)
        {
            oppList1.add(new Opportunity(Name = 'oppTest0',AccountId=acc1.Id,StageName='RFP',CloseDate=Date.today(),recordtypeId=RecTypeNameflight));
            
            oppList1.add(new Opportunity(Name = 'oppTest1',AccountId=acc1.Id,StageName='Closed Won',CloseDate=Date.today()+1,recordtypeId=RecTypeNameflight));
            
            oppList1.add(new Opportunity(Name = 'oppTest2',AccountId=acc1.Id,StageName='Prospecting',CloseDate=Date.today()+2,recordtypeId=RecTypeNameflight));
            
            oppList1.add(new Opportunity(Name = 'oppTest3',AccountId=acc1.Id,StageName='Qualification',CloseDate=Date.today()+3,recordtypeId=RecTypeNameflight));
            
            oppList1.add(new Opportunity(Name = 'oppTest4',AccountId=acc1.Id,StageName='Proposal',CloseDate=Date.today()+4,recordtypeId=RecTypeNameflight));
            
            oppList1.add(new Opportunity(Name = 'oppTest5',AccountId=acc1.Id,StageName='Proposal Engaged',CloseDate=Date.today()+5,recordtypeId=RecTypeNameflight));
            
            oppList1.add(new Opportunity(Name = 'oppTest6',AccountId=acc1.Id,StageName='Running',CloseDate=Date.today()+6,recordtypeId=RecTypeNameflight));
            
            oppList1.add(new Opportunity(Name = 'oppTest7',AccountId=acc1.Id,StageName='Scale',CloseDate=Date.today()+7,recordtypeId=RecTypeNameflight));
            
            oppList1.add(new Opportunity(Name = 'oppTest8',AccountId=acc1.Id,StageName='Closed Lost',CloseDate=Date.today()+8,recordtypeId=RecTypeNameflight));

        }
        insert oppList1;
        List<opportunity> listOpp1 = [select id from opportunity where AccountId =: acc1.Id ];
        System.assertEquals(listOpp1.size(),27);
        
        test.startTest();
            ApexPages.StandardController sc = new ApexPages.StandardController(acc);
            AccountRelatedOpportunitiesController obj = new AccountRelatedOpportunitiesController(sc);
            obj.getLstOpportunities();
            System.assert(listOpp.size() > 0);
            obj.first();
            obj.last();
            obj.previous();
            obj.next();
            obj.cancel(); 
            Boolean hasNextMethod = obj.hasNext;
            System.assertEquals(hasNextMethod,true);
            Boolean hasPreviousMethod = obj.hasPrevious;
            Integer pageNumberMethod = obj.pageNumber;
            System.assertEquals(pageNumberMethod,6);   
        test.stopTest();
    }
}