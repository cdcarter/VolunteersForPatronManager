public with sharing class V4PM_Controller {
	public PatronTicket__TicketableEvent__c[] tes {get; set;}
	public PatronTicket__TicketableEvent__c ticketableEvent {get; set;}
	public Campaign volunteerCampaign {get;set;}
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
		}
		
	}

	public PageReference submit(){
		// create a campaign for the TE
		volunteerCampaign = new Campaign();
		volunteerCampaign.Name = ticketableEvent.Name + 'Volunteers';
		volunteerCampaign.TicketableEvent__c = ticketableEvent.Id;
		volunteerCampaign.Venue__c = eventInstances[0].eventInstance.PatronTicket__Venue__c;
		volunteerCampaign.IsActive = true;
		volunteerCampaign.Status = 'Planned';
		// find the jobs for that volunteer campaign
		List<GW_Volunteers__Volunteer_Job__c> jobs = [SELECT Id,Name,Event_Volunteer_Notes__c,Volunteer_sees_show__c,GW_Volunteers__Inactive__c,GW_Volunteers__Display_on_Website__c,GW_Volunteers__Description__c,GW_Volunteers__Campaign__c FROM GW_Volunteers__Volunteer_Job__c]; //WHERE GW_Volunteers__Campaign__c =:]
		// for each job create a job for that TE
		// for each job find the shifts
		// for each shift calculate the offset
		// for each shift create a shift for that EI
		return Page.V4PM_Submit;
	}

	public class eiInstance {
		public PatronTicket__EventInstance__c eventInstance {get;set;}
		public Integer idx {get;set;}
		public String campaign {get;set;}
		public List<SelectOption> options {get; set;}
		public eiInstance(PatronTicket__EventInstance__c ei,Integer j) {
			idx = j;
			eventInstance = ei;
			options = new List<SelectOption>();
			List<Campaign> prototypes = [SELECT Id,Name FROM Campaign WHERE Venue__c = :eventInstance.PatronTicket__Venue__c];
			for(Integer i = 0; i < prototypes.size(); i++) {
				SelectOption option = new SelectOption(prototypes[i].Id,prototypes[i].Name);
				options.add(option);
			}
		}
	}
}