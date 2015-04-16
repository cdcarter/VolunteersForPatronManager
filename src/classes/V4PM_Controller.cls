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
													PatronTicket__Venue__c,Volunteer_Shift__c 
													FROM PatronTicket__EventInstance__c 
													WHERE PatronTicket__TicketableEvent__c = :id]) {
				eis.add(new eiInstance(e,idx));
				idx++;
			}
		}
		
	}

	public PageReference submit(){
		// create a campaign for the TE
		volunteerCampaign = new Campaign();
		volunteerCampaign.Name = ticketableEvent.Name + ' Volunteers';
		volunteerCampaign.TicketableEvent__c = ticketableEvent.Id;
		volunteerCampaign.Venue__c = eis[0].eventInstance.PatronTicket__Venue__c;
		volunteerCampaign.IsActive = true;
		volunteerCampaign.Status = 'Planned';
		volunteerCampaign.RecordTypeId = [Select Id From RecordType Where SObjectType = 'Campaign' And DeveloperName='Volunteers_Campaign'].Id;
		insert volunteerCampaign;
		List<GW_Volunteers__Volunteer_Job__c> newJobs = new List<GW_Volunteers__Volunteer_Job__c>();
		List<GW_Volunteers__Volunteer_Shift__c> newShifts = new List<GW_Volunteers__Volunteer_Shift__c>();

		// loop through the wrapper collection and split it out into Lists of the data we want
		List<Id> campaignIds = new List<Id>();
		List<PatronTicket__EventInstance__c> eventInstances = new List<PatronTicket__EventInstance__c>();

		for(Integer i = 0;i < eis.size(); i++) {
			eventInstances.add(eis[i].eventInstance);
			campaignIds.add(eis[i].campaign);
		}
		
		// create a set of the prototype campaigns we actually use
		Map<Id,Campaign> campaignMap = new Map<Id,Campaign>([Select Id,Name,Event_Start_Time__c FROM Campaign WHERE Id IN :campaignIds]);
		List<Campaign> campaigns = campaignMap.values();
		Map<Id,List<GW_Volunteers__Volunteer_Job__c>> jobMap = new Map<Id,List<GW_Volunteers__Volunteer_Job__c>>();
		Map<Id,GW_Volunteers__Volunteer_Job__c> prototypeIdToJob = new Map<Id,GW_Volunteers__Volunteer_Job__c>();
		// iterate through that set, and create the jobs we are using
		for(Integer i=0; i < campaigns.size(); i++) {
			List<GW_Volunteers__Volunteer_Job__c> jobs = [SELECT Id,Name,
																Volunteer_sees_show__c,GW_Volunteers__Inactive__c,
																GW_Volunteers__Display_on_Website__c,
																GW_Volunteers__Description__c,
																GW_Volunteers__Campaign__c 
																FROM GW_Volunteers__Volunteer_Job__c 
																WHERE GW_Volunteers__Campaign__c =:campaigns[i].Id];
			jobMap.put(campaigns[i].Id,jobs);
			for(Integer j=0; j < jobs.size();j++){
				GW_Volunteers__Volunteer_Job__c currentJob = new GW_Volunteers__Volunteer_Job__c(
								Name=jobs[j].Name+' '+campaigns[i].Name,
								Event_Volunteer_Notes__c = ticketableEvent.Volunteer_Notes__c,
								Volunteer_sees_show__c = jobs[j].Volunteer_sees_show__c,
								GW_Volunteers__Inactive__c = jobs[j].GW_Volunteers__Inactive__c,
								GW_Volunteers__Display_on_Website__c = jobs[j].GW_Volunteers__Display_on_Website__c,
								GW_Volunteers__Description__c = jobs[j].GW_Volunteers__Description__c,
								GW_Volunteers__Campaign__c = volunteerCampaign.Id);
				prototypeIdToJob.put(jobs[j].Id,currentJob);
				newJobs.add(currentJob);
			}
		}
		insert newJobs;

		// get all the prototype shifts for all represented jobs
		List<GW_Volunteers__Volunteer_Shift__c> prototypeShifts = new List<GW_Volunteers__Volunteer_shift__c>([
			SELECT Id,GW_Volunteers__Description__c,GW_Volunteers__Desired_Number_of_Volunteers__c,
				   GW_Volunteers__Duration__c, GW_Volunteers__Start_Date_Time__c,GW_Volunteers__Total_Volunteers__c,
				   GW_Volunteers__System_Note__c,GW_Volunteers__Volunteer_Job__c, 
				   GW_Volunteers__Volunteer_Job__r.GW_Volunteers__Campaign__c,
				   GW_Volunteers__Volunteer_Job__r.GW_Volunteers__Campaign__r.Event_Start_Time__c
				   FROM GW_Volunteers__Volunteer_Shift__c
				   WHERE GW_Volunteers__Volunteer_Job__c IN :new List<Id>(prototypeIdToJob.keySet())]);

		for(Integer i=0; i < eventInstances.size(); i++) {
			Id campaignId = campaignIds[i];
			for(Integer j=0; j < prototypeShifts.size();j++){
				GW_Volunteers__Volunteer_Shift__c proto = prototypeShifts[j];
				Long timeDiff = proto.GW_Volunteers__Volunteer_Job__r.GW_Volunteers__Campaign__r.Event_Start_Time__c.getTime() - proto.GW_Volunteers__Start_Date_Time__c.getTime();
				Time newTime = eventInstances[i].PatronTicket__InstanceDate__c.time().addMilliseconds(-timeDiff.intValue());
				DateTime newDateTime = DateTime.newInstance(eventInstances[i].PatronTicket__InstanceDate__c.date(),newTime);
				if (proto.GW_Volunteers__Volunteer_Job__r.GW_Volunteers__Campaign__c == campaignId) {
					GW_Volunteers__Volunteer_Shift__c shift = new GW_Volunteers__Volunteer_Shift__c(
						GW_Volunteers__Description__c = proto.GW_Volunteers__Description__c,
						GW_Volunteers__Desired_Number_of_Volunteers__c = proto.GW_Volunteers__Desired_Number_of_Volunteers__c,
						GW_Volunteers__Duration__c = proto.GW_Volunteers__Duration__c,
						GW_Volunteers__Total_Volunteers__c = proto.GW_Volunteers__Total_Volunteers__c,
						GW_Volunteers__System_Note__c = proto.GW_Volunteers__System_Note__c,
						GW_Volunteers__Volunteer_Job__c = prototypeIdToJob.get(proto.GW_Volunteers__Volunteer_Job__c).Id,
						GW_Volunteers__Start_Date_Time__c = newDateTime);
					newShifts.add(shift);
				}
			}
		}
		
		insert newShifts;

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
			List<Campaign> prototypes = [SELECT Id,Name 
										 FROM Campaign 
										 WHERE Venue__c = :eventInstance.PatronTicket__Venue__c];
			for(Integer i = 0; i < prototypes.size(); i++) {
				SelectOption option = new SelectOption(prototypes[i].Id,prototypes[i].Name);
				options.add(option);
			}
		}
	}
}