public with sharing class V4PM_VolunteerBuild {
	public static Campaign build(PatronTicket__TicketableEvent__c ticketableEvent,Map<PatronTicket__EventInstance__c,Id> eis) {
		// create a campaign for the TE
		Campaign volunteerCampaign = new Campaign();
		volunteerCampaign.Name = ticketableEvent.Name + ' Volunteers';
		volunteerCampaign.TicketableEvent__c = ticketableEvent.Id;
		volunteerCampaign.Venue__c = (new List<PatronTicket__EventInstance__c>(eis.keySet()))[0].PatronTicket__Venue__c;
		volunteerCampaign.IsActive = true;
		volunteerCampaign.Status = 'Planned';
		volunteerCampaign.RecordTypeId = [Select Id From RecordType Where SObjectType = 'Campaign' And DeveloperName='Volunteers_Campaign'].Id;
		insert volunteerCampaign;
		ticketableEvent.Volunteer_Campaign__c = volunteerCampaign.Id;
		update ticketableEvent;
		List<GW_Volunteers__Volunteer_Job__c> newJobs = new List<GW_Volunteers__Volunteer_Job__c>();
		List<GW_Volunteers__Volunteer_Shift__c> newShifts = new List<GW_Volunteers__Volunteer_Shift__c>();
		
		// create a set of the prototype campaigns we actually use
		Map<Id,Campaign> campaignMap = new Map<Id,Campaign>([Select Id,Name,Event_Start_Time__c FROM Campaign WHERE Id IN :eis.values()]);
		List<Campaign> campaigns = campaignMap.values();
		Map<Id,List<GW_Volunteers__Volunteer_Job__c>> jobMap = new Map<Id,List<GW_Volunteers__Volunteer_Job__c>>();
		Map<Id,GW_Volunteers__Volunteer_Job__c> prototypeIdToJob = new Map<Id,GW_Volunteers__Volunteer_Job__c>();

		List<GW_Volunteers__Volunteer_Job__c> allJobs =	[SELECT Id,Name,
																Volunteer_sees_show__c,GW_Volunteers__Inactive__c,
																GW_Volunteers__Display_on_Website__c,
																GW_Volunteers__Description__c,
																GW_Volunteers__Campaign__c,
																GW_Volunteers__Location_Street__c,
																GW_Volunteers__Location_City__c,
																GW_Volunteers__Location__c,
																GW_Volunteers__Location_Zip_Postal_Code__c,
																GW_Volunteers__Location_Information__c
																FROM GW_Volunteers__Volunteer_Job__c 
																WHERE GW_Volunteers__Campaign__c  IN :campaignMap.keySet()];

		// iterate through that set, and create the jobs we are using
		for(Campaign c:campaigns) {

			jobMap.put(c.Id,new List<GW_Volunteers__Volunteer_Job__c>());
			for(GW_Volunteers__Volunteer_Job__c job : allJobs){
				if (job.GW_Volunteers__Campaign__c == c.Id) {
					GW_Volunteers__Volunteer_Job__c currentJob = new GW_Volunteers__Volunteer_Job__c(
									Name=job.Name,
									Event_Volunteer_Notes__c = ticketableEvent.Volunteer_Notes__c,
									Volunteer_sees_show__c = job.Volunteer_sees_show__c,
									GW_Volunteers__Inactive__c = job.GW_Volunteers__Inactive__c,
									GW_Volunteers__Display_on_Website__c = job.GW_Volunteers__Display_on_Website__c,
									GW_Volunteers__Description__c = job.GW_Volunteers__Description__c,
									GW_Volunteers__Campaign__c = volunteerCampaign.Id,
									GW_Volunteers__Location_Street__c = job.GW_Volunteers__Location_Street__c,
									GW_Volunteers__Location_City__c = job.GW_Volunteers__Location_City__c,
									GW_Volunteers__Location__c = job.GW_Volunteers__Location__c,
									GW_Volunteers__Location_Zip_Postal_Code__c = job.GW_Volunteers__Location_Zip_Postal_Code__c,
									GW_Volunteers__Location_Information__c = job.GW_Volunteers__Location_Information__c);
					prototypeIdToJob.put(job.Id,currentJob);
					newJobs.add(currentJob);
					jobMap.get(c.Id).add(job);
				}
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

		for(PatronTicket__EventInstance__c eventInstance : eis.keySet()) {
				Id campaignId = eis.get(eventInstance);
				for(GW_Volunteers__Volunteer_Shift__c proto: prototypeShifts){
					Long timeDiff = proto.GW_Volunteers__Volunteer_Job__r.GW_Volunteers__Campaign__r.Event_Start_Time__c.getTime() - proto.GW_Volunteers__Start_Date_Time__c.getTime();
					Time newTime = eventInstance.PatronTicket__InstanceDate__c.time().addMilliseconds(-timeDiff.intValue());
					DateTime newDateTime = DateTime.newInstance(eventInstance.PatronTicket__InstanceDate__c.date(),newTime);
					if (proto.GW_Volunteers__Volunteer_Job__r.GW_Volunteers__Campaign__c == campaignId) {
						GW_Volunteers__Volunteer_Shift__c shift = new GW_Volunteers__Volunteer_Shift__c(
							GW_Volunteers__Description__c = proto.GW_Volunteers__Description__c,
							GW_Volunteers__Desired_Number_of_Volunteers__c = proto.GW_Volunteers__Desired_Number_of_Volunteers__c,
							GW_Volunteers__Duration__c = proto.GW_Volunteers__Duration__c,
							GW_Volunteers__System_Note__c = proto.GW_Volunteers__System_Note__c,
							GW_Volunteers__Volunteer_Job__c = prototypeIdToJob.get(proto.GW_Volunteers__Volunteer_Job__c).Id,
							GW_Volunteers__Start_Date_Time__c = newDateTime,
							EventInstance__c = eventInstance.Id);
						newShifts.add(shift);
					}
				}
		}
		
		insert newShifts;
		return volunteerCampaign;
	}
}