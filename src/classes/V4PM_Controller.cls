public with sharing class V4PM_Controller {
	public PatronTicket__TicketableEvent__c ticketableEvent {get; set;}
	public List<eiInstance> eis {get; set;}

	public V4PM_Controller() {
		String id = ApexPages.CurrentPage().getParameters().get('id');
		if (String.isNotBlank(id)) {
			ticketableEvent = [SELECT Id,Name,PatronTicket__Active__c,Volunteer_Campaign__c,
							   Volunteer_Notes__c,PatronTicket__Description__c,PatronTicket__Detail__c,
							   Duration_hours__c FROM PatronTicket__TicketableEvent__c 
							   WHERE Id = :id];
			Id rtid = [Select Id From RecordType Where SObjectType = 'Campaign' And DeveloperName='Venue_Prototype'].Id;

			List<PatronTicket__Venue__c> venues = [Select Id,Name,
			    (SELECT Id,Name,PatronTicket__InstanceDate__c,
						PatronTicket__Active__c,PatronTicket__Detail__c,
						PatronTicket__SeatingType__c,PatronTicket__TicketableEvent__c,
						PatronTicket__Venue__c
			     FROM PatronTicket__Event_Instances__r 
			     WHERE PatronTicket__TicketableEvent__c = :id
			    ),
			    (SELECT Id,Name,Venue__c
			     FROM Campaigns__r
			     WHERE RecordTypeId =: rtid
			    )
			    FROM PatronTicket__Venue__c 
			    WHERE Id IN 
			    (SELECT PatronTicket__Venue__c 
			     FROM PatronTicket__EventInstance__c 
			     WHERE PatronTicket__TicketableEvent__c = :id
			    )
			];
			
			List<PatronTicket__EventInstance__c> instances = new List<PatronTicket__EventInstance__c>();
			List<Campaign> campaigns = new List<Campaign>();
			
			for(PatronTicket__Venue__c v:venues) {
				List<PatronTicket__EventInstance__c> theeis = v.getSobjects('PatronTicket__Event_Instances__r');
			    if (!theeis.isEmpty()) {
			    	instances.addAll(theeis);
			    }

			    List<Campaign> cs = v.getSobjects('Campaigns__r');
			    if (cs != null ) {
			    	campaigns.addAll(cs);
			    }
			}

			eis = new List<eiInstance>();
			for (PatronTicket__EventInstance__c e: instances) {
				eis.add(new eiInstance(e,campaigns));
			}
		}
		
	}

	public PageReference submit(){
		Map<PatronTicket__EventInstance__c,Id> eiMap = new Map<PatronTicket__EventInstance__c,Id>();
		for(eiInstance e: eis) {
			if (e.build) {
				eiMap.put(e.eventInstance, (Id)e.campaign);
			}
		}

		Campaign volunteerCampaign = V4PM_VolunteerBuild.build(ticketableEvent,eiMap);

		return new ApexPages.StandardController(volunteerCampaign).view();
	}

	public class eiInstance {
		public PatronTicket__EventInstance__c eventInstance {get;set;}
		public String campaign {get;set;}
		public Boolean build {get;set;}
		public List<SelectOption> options {get; set;}
		public eiInstance(PatronTicket__EventInstance__c ei, List<Campaign> prototypes) {
			eventInstance = ei;
			options = new List<SelectOption>();
			build = true;
			for(Campaign c:prototypes) {
				if (c.Venue__c == ei.PatronTicket__Venue__c) {
					SelectOption option = new SelectOption(c.Id,c.Name);
					options.add(option);
				}
				if (options.isEmpty()) {
					build = false;
				}
			}
		}
	}
}