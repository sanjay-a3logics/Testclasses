trigger OpportunityPartnerSync on Opportunity (after insert, after update) {
  
  Set<ID> OppIds = Trigger.newMap.keySet();
  List<Opportunity> opp = [Select id, Agency__c, Account.id from Opportunity where id IN:OppIds and Agency__c <> null ];
  System.debug(opp.size()); 
  if(opp.size()==0)
  {
  	return;
  }
  
  Set<ID> AgencyIds = New Set<ID>();
  Set<ID> Accounts = New Set<ID>();
  
  for(Opportunity o : opp) {
  	if(o.Agency__c<>null && o.Account.id<>null)
  	{
  	AgencyIds.add(o.Agency__c);
  	Accounts.add(o.Account.id);  	
  	}
  	
  }
  Map<ID,MAP<ID,boolean>> partnerLookup= new Map<ID,MAP<ID,boolean>>();
   
  List<Partner> aps=  [Select AccountToId,AccountFromId,Role 
  from Partner WHERE  role='Billing Agency' AND (AccountToId IN :AgencyIds OR AccountFromID IN:Accounts) ];
  
  System.debug('APList');
  System.debug(aps);
  for(Partner AP: aps)
  {
  	
  	if(!partnerLookup.containsKey(AP.AccountFromId))
  	{
  		Map<ID,boolean> inserter = new Map<ID,boolean>();  		
  		inserter.put(AP.AccountToId,false);
  		partnerLookup.put(AP.AccountFromId,inserter);
  	}	
  	else
  	{
  		Map<Id,boolean> subMap =partnerLookup.get(AP.AccountFromid);
  		if(!subMap.containsKey(AP.AccountToId))
  		{
  			subMap.put(AP.AccountToId,false);
  		}
  	}
  }
  
  List<Partner> partnerToInsert = new List<Partner>();
  
  for(Opportunity o1: opp)
  {
  	 
  	if(partnerLookup.containsKey(o1.Account.id))
  	{
  		Map<Id,Boolean> temp =partnerLookup.get(o1.Account.id);
  		System.debug('temp is');
  		System.debug(temp);
  		if(temp.containsKey(o1.Agency__c))
  		{
  			continue;
  		}
  	}
  		//AccountPartner newP = new AccountPartner();
  		if(o1.Agency__c<>null)
  		{
		Partner newP = new Partner();  	
		newP.role ='Billing Agency';
		newP.AccountToId =  o1.Agency__c;
		NewP.AccountFromId =o1.Account.id;		
		partnerToInsert.add(newP);
  		}
  	
  }
  system.debug(partnerToInsert);
  insert partnerToInsert;
  
  system.debug('key');  
  List<Partner> part1 = [Select id from Partner];
  
  system.debug(part1);
  
  
    
}