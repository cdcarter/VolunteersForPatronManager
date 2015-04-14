public with sharing class V4PM_Controller {
	public PatronTicket__TicketableEvent__c[] tes {get; set;}
	public PatronTicket__TicketableEvent__c ticketableEvent {get; set;}
	public List<eiInstance> eventInstances {get; set;}
	public Campaign[] prototypes;
	public V4PM_Controller() {
		tes = [SELECT Id,Name,PatronTicket__Active__c FROM PatronTicket__TicketableEvent__c WHERE PatronTicket__Active__c = true];
		String id = ApexPages.CurrentPage().getParameters().get('id');
		if (String.isNotBlank(id)) {
			ticketableEvent = [SELECT Id,Name,PatronTicket__Active__c,Volunteer_Campaign__c,Volunteer_Notes__c,PatronTicket__Description__c,PatronTicket__Detail__c,Duration_hours__c FROM PatronTicket__TicketableEvent__c WHERE Id = :id];
			eventInstances = new List<eiInstance>();
			Integer idx = 0;
			for (PatronTicket__EventInstance__c e: [SELECT Id,Name,PatronTicket__InstanceDate__c,PatronTicket__Active__c,PatronTicket__Detail__c,PatronTicket__SeatingType__c,PatronTicket__TicketableEvent__c,PatronTicket__Venue__c,Volunteer_Shift__c FROM PatronTicket__EventInstance__c WHERE PatronTicket__TicketableEvent__c = :id]) {
				eventInstances.add(new eiInstance(e,idx));
				idx++;
			}
			prototypes = [SELECT Id,Name FROM Campaign WHERE Venue__c = :eventInstances[0].eventInstance.PatronTicket__Venue__c];
		}
		
	}

	public List<SelectOption> getPrototypes() {
		List<SelectOption> options = new List<SelectOption>();
		for(Integer i = 0; i < prototypes.size(); i++) {
			SelectOption option = new SelectOption(prototypes[i].Id,prototypes[i].Name);
			options.add(option);
		}
		return options;
	}

	public class eiInstance {
		public PatronTicket__EventInstance__c eventInstance {get;set;}
		public Integer idx {get;set;}
		public Campaign campaign {get;set;}
		public eiInstance(PatronTicket__EventInstance__c ei,Integer i) {
			idx = i;
			eventInstance = ei;
		}
	}
}