public with sharing class V4PM_Controller {
	public PatronTicket__TicketableEvent__c[] tes {get; set;}
	public PatronTicket__TicketableEvent__c ticketableEvent {get; set;}
	public Campaign volunteerCampaign {get;set;}
	public List<eiInstance> eis {get; set;}
	public Campaign[] prototypes;
	public V4PM_Controller() {
		tes = [SELECT Id,Name,PatronTicket__Active__c 
			   FROM PatronTicket__TicketableEvent__c 
			   WHERE PatronTicket__Active__c = true];
		String id = ApexPages.CurrentPage().getParameters().get('id');
		if (String.isNotBlank(id)) {
			ticketableEvent = [SELECT Id,Name,PatronTicket__Active__c,Volunteer_Campaign__c,
							   Volunteer_Notes__c,PatronTicket__Description__c,PatronTicket__Detail__c,
							   Duration_hours__c FROM PatronTicket__TicketableEvent__c 
							   WHERE Id = :id];
			eis = new List<eiInstance>();
			Integer idx = 0;
			for (PatronTicket__EventInstance__c e: [SELECT Id,Name,PatronTicket__InstanceDate__c,
													PatronTicket__Active__c,PatronTicket__Detail__c,
													PatronTicket__SeatingType__c,PatronTicket__TicketableEvent__c,
													PatronTicket__Venue__c 
													FROM PatronTicket__EventInstance__c 
													WHERE PatronTicket__TicketableEvent__c = :id]) {
				eis.add(new eiInstance(e,idx));
				idx++;
			}
		}
		
	}

	public PageReference submit(){
		volunteerCampaign = V4PM_VolunteerBuild.build(ticketableEvent,eis);

		return new ApexPages.StandardController(volunteerCampaign).view();
	}
}