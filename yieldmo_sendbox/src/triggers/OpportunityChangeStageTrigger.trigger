trigger OpportunityChangeStageTrigger on Opportunity (after insert, after update) {

  RecordType parentRecord = [Select id from RecordType where Name='Parent' and SObjectType='Opportunity' ];
  Set<ID> OppIds = Trigger.newMap.keySet();
    
  List<Opportunity> Child = [Select id,parent_opportunity__C,stageName from Opportunity where parent_opportunity__C IN:OppIds and RecordTypeId<>:parentRecord.id];
  
  
  Map<ID,List<Opportunity>> childrenStage = new Map<Id,List<Opportunity>>();
  for(Opportunity o: Child)
  {
  		if(!childrenStage.containsKey(o.parent_opportunity__C))
  		{
  			List<Opportunity> oppList = new List<Opportunity> ();
  			childrenStage.put(o.parent_opportunity__C,oppList);
  		}
  		(childrenStage.get(o.parent_opportunity__C)).add(o);
  }
  
  List<Opportunity> parentOpps = [Select id,stageName from Opportunity where id IN:OppIds and RecordTypeId=:parentRecord.id];
  System.debug(parentOpps);
  List<Opportunity> updateList = new List<Opportunity> (); 
  
  for(Opportunity ParentOpp : parentOpps)
  {
  	if(childrenStage.containsKey(ParentOpp.id))
  	{
  		List<Opportunity> oppList = childrenStage.get(ParentOpp.id);
  		String newStage = ParentOpp.StageName+'-Child';
  		for(Opportunity childOpp : oppList)
  		{
  			if(childOpp.StageName<>newStage)
  			{
  				childOpp.stageName=newStage;
  				updateList.add(childOpp);
  			}
  		}
  	}  	
  }
  update updateList;
  
  
  
  
}