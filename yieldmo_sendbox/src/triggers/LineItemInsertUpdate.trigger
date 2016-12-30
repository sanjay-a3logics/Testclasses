trigger LineItemInsertUpdate on OpportunityLineItem (after insert, after update) {
	
	
	
 	Set<ID> OppLineIds = Trigger.newMap.keySet();
 	RecordType parent= [Select id from RecordType where name= 'Parent' and sObjectType= 'Opportunity' and isActive=true];
 	
 	List<OpportunityLineItem > parentOpportunities_base =
 		[Select OpportunityID
 		from OpportunityLineItem where Opportunity.RecordTypeId=:parent.id //Parent 
 		and HasRevenueSchedule=true
 		and  ID IN:OppLineIds ]; 
 	
 	Set<ID> parentOpportunities = new Set<Id>();
 	for(OpportunityLineItem item : parentOpportunities_base)
 	{
 		parentOpportunities.add(item.OpportunityID);
 	}
 	
 	if(parentOpportunities.size()==0)
 	{
 		return;
 	}
 	

	
	
 	//Query Child to get it as it Exists in the flights
 	AggregateResult[] currentOpportunitySpan = [Select Parent_Opportunity__c,MIN(CloseDate) minimum,MAX(CloseDate) maximum From Opportunity where Parent_Opportunity__c IN:parentOpportunities group by Parent_Opportunity__c];
 	
 	//Query Parents Line Items to get how it should be
 	AggregateResult[] futureOpportunitySpan = [Select OpportunityId,MIN(Campaign_Start_date__C) minimum,MAX(Campaign_end_date__C) maximum from OpportunityLineItem where OpportunityId IN:parentOpportunities group by OpportunityId  ];
 	
 	
 	List<Opportunity> OppList = [Select ID,AccountID,Name,StageName,CloseDate from Opportunity Where iD IN:parentOpportunities ];
 	Map<id,Opportunity> OppMap = new Map<id,Opportunity> ();
 	for(Opportunity o : OppList)
 	{
 		OppMap.put(o.id,o);
 	} 
 	Map<ID,Date> starts = new MAP<ID,Date>();
 	Map<ID,Date> ends = new MAP<ID,Date>();
 	for(Integer i=0;i<currentOpportunitySpan.Size();i++)
 	{
 		ID id = (ID)currentOpportunitySpan[i].get('Parent_Opportunity__c');
 		Date Start = ((Date)currentOpportunitySpan[i].get('minimum')).toStartOfMonth();
 		Date FutureEnd = ((Date)currentOpportunitySpan[i].get('maximum')).toStartOfMonth();
 		starts.put(id,Start);
 		ends.put(id,FutureEnd );
 		
 	}
 	
 	List<Opportunity> missingOpportunities = new List<Opportunity>();
 	system.debug('futureSpan:'+futureOpportunitySpan);
 	for(Integer i=0;i<futureOpportunitySpan.Size();i++)
 	{
 		ID OppId= ((ID)futureOpportunitySpan[i].get('OpportunityId'));
 		Date currentStart= ((Date)futureOpportunitySpan[i].get('minimum')).toStartOfMonth();
 		Date currentEnd= ((Date)futureOpportunitySpan[i].get('maximum')).toStartOfMonth();
 		
 		//If its not there, add them all
 		if(!starts.containsKey(OppId))
 		{
 			for(Date close= currentStart;close<=currentEnd;close=close.addMonths(1))
 			{
 				Opportunity child = new Opportunity();
 				child.Parent_Opportunity__c = OppId;
 				child.closeDate =close;
 				child.recordTypeId='012210000004OihAAE';
 				child.accountId = OppMap.get(OppId).AccountId;
 				child.Name='z-'+OppMap.get(oppId).Name+'-'+OppMap.get(oppId).closeDate;
 				child.StageName=OppMap.get(oppId).StageName;
 				System.debug('child='+child);
 				missingOpportunities.add(child);
 			}
 		}
 		else 
 		{
 		
 		System.debug('Current Start:'+currentStart);
 			System.debug('starts.get(OppId):'+starts.get(OppId));	
 			if(currentStart < starts.get(OppId))
 			{
 				for(Date close= currentStart;close<starts.get(OppId);close=close.addMonths(1))
 				{
	 				Opportunity child = new Opportunity();
	 				child.Parent_Opportunity__c = OppId;
 					child.closeDate =close;
 					child.recordTypeID='012210000004OihAAE';
 					child.accountId = OppMap.get(OppId).AccountId;
 					child.name='z-'+OppMap.get(oppId).Name+'-'+OppMap.get(oppId).closeDate;
 					child.StageName=OppMap.get(oppId).StageName;
 					missingOpportunities.add(child);
 				}
 				
 			}
 			
 			//If Current End < Futute End, Add Missing Ones between
 			if(currentEnd > Ends.get(OppId))
 			{
 				for(Date close= currentEnd;close>Ends.get(OppId);close=close.addMonths(-1))
 				{
 					Opportunity child = new Opportunity();
	 				child.Parent_Opportunity__c = OppId;
 					child.closeDate =close;
 					child.recordTypeID='012210000004OihAAE';
 					child.accountId = OppMap.get(OppId).AccountId;
 					child.name='z-'+OppMap.get(oppId).Name+'-'+OppMap.get(oppId).closeDate;
 				child.StageName=OppMap.get(oppId).StageName;
 					missingOpportunities.add(child);
 				}
 			}
 			
 		}//End Else
 	}//Close For Loop
 	System.debug('missingOpportunities='+missingOpportunities);
 	insert missingOpportunities;
 	//Now have all Opportunities loaded
 	
 	//Now delete All LineItems from Flighted Opportunities
 	List<OpportunityLineItem> oppLineItems = [Select ID FROM OpportunityLineItem where Opportunity.Parent_Opportunity__c IN: parentOpportunities];
 	delete oppLineItems ;
 	
 	List<Opportunity> fullChildOpps = [Select ID,CloseDate,Parent_opportunity__c from Opportunity where Parent_opportunity__c IN : parentOpportunities];
 	
 	
 	//Now we have all Clean Opportunities
 	List<OpportunityLineItem> lineItemList = [Select ID,OpportunityID,PriceBookEntryId,Product2Id,Objective__c,Pricing_method__C  From OpportunityLineItem where ID IN: OppLineIds ];
 	Map<Id,List<OpportunityLineItem>> oppToLineItemLookup = new Map<Id,List<OpportunityLineItem>> ();
 	
 	for(OpportunityLineItem item: lineItemList )
 	{
 		if(!oppToLineItemLookup.containsKey(item.OpportunityId))
 		{
 			List<OpportunityLineItem> newList = new List<OpportunityLineItem>();
 			oppToLineItemLookup.put(item.OpportunityId,newList);
 		}
 		oppToLineItemLookup.get(item.OpportunityId).add(item);
 	}
 	
 	
 	List<OpportunityLineItemSchedule> schedules = [Select OpportunityLineItemId,ScheduleDate,Revenue from OpportunityLineItemSchedule where OpportunityLineItemId IN: OppLineIds ];
 	Map<ID,Map<Date,double>> scheduleLookup = new Map<ID,Map<Date,double>> ();
 	
 	for(OpportunityLineItemSchedule sched : schedules  )
 	{
 		if(!scheduleLookup.containsKey(sched.OpportunityLineItemId))
 		{
 			Map<Date,double> newMap = new Map<Date,double>();
 			scheduleLookup.put(sched.OpportunityLineItemId,newMap);
 		}
 		ScheduleLookup.get(sched.OpportunityLineItemId).put(Sched.ScheduleDate,Sched.Revenue);
 	}
 	 
 	List<OpportunityLineItem> toAdd = new List<OpportunityLineItem> ();
 	System.debug('oppToLineItemLookup');
 	System.debug(oppToLineItemLookup);
 	for(Opportunity opp:fullChildOpps)
 	{
 		List<OpportunityLineItem> lineList = new List<OpportunityLineItem> ();
 		System.debug('Opp:' + opp);
 		for(OpportunityLineItem li :oppToLineItemLookup.get(opp.Parent_Opportunity__c) )
 		{
 			if(scheduleLookup.get(li.id).get(opp.closeDate)!=null)
 			{
 			OpportunityLineItem newLi = new OpportunityLineItem ();
 			newLi.OpportunityId = opp.id;
 			newLi.Quantity=1;
 			newLi.PriceBookEntryId=li.PriceBookEntryId;
 			newLi.TotalPrice =scheduleLookup.get(li.id).get(opp.closeDate);  
 			newLi.objective__c= li.objective__c;
 			newLi.pricing_method__c= li.pricing_method__c;
 			System.debug('Adding New LI:' + newLi);
 			toAdd.add(newLi);
 			} 			
 		}
 	}
 	
 	insert toAdd;
 	
 	
 	
}