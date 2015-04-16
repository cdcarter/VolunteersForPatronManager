@isTest
private class V4PM_VolunteerBuild_TEST
{
	@testSetup static void setup() {
		// Create the Venue
		PatronTicket__Venue__c v = new PatronTicket__Venue__c(Name='Bagley Wright', PatronTicket__Active__c = true,
								PatronTicket__AddressInformation__c='155 Mercer St, Seattle, WA 98109',
								PatronTicket__Detail__c ='The Bagley Wright is the mainstage at SRT',
								PatronTicket__DisplayName__c='The Bagley Wright Theatre at Seattle Rep');
		insert v;

		// Create a Ticketable Event
		PatronTicket__TicketableEvent__c te = new PatronTicket__TicketableEvent__c(Name='Party Hardy',
												  PatronTicket__Active__c = true,
												  Duration_hours__c = 2,
												  Volunteer_Notes__c = 'This one is gonna be fun');
		insert te;

		// Create a few Instances
		List<PatronTicket__EventInstance__c> eis = new List<PatronTicket__EventInstance__c>();
		for(Integer i=1; i <5; i++) {
			DateTime theDate = DateTime.newInstance(2015, 4, i, 14, 0, 0);
			PatronTicket__EventInstance__c ei = new PatronTicket__EventInstance__c(Name='Instance #'+i,
													PatronTicket__Active__c = true,
													PatronTicket__InstanceDate__c = theDate,
													PatronTicket__TicketableEvent__c = te.Id,
													PatronTicket__Venue__c = v.Id);
			eis.add(ei);
		}
		insert eis;

		// Create Prototype Campaigns
		Id prototypeCampaignType =  [SELECT Id FROM RecordType 
										WHERE SObjectType = 'Campaign' AND DeveloperName='Venue_Prototype'].Id;
		Campaign c = new Campaign(Name='Volunteers GA',
								  IsActive = true,
								  RecordTypeId = prototypeCampaignType,
								  Event_Start_Time__c = DateTime.newInstance(2015, 4, 1, 14, 0, 0),
								  Venue__c = v.Id);
		insert c;
		Campaign cc = new Campaign(Name='Volunteers Reserved',
								  IsActive = true,
								  RecordTypeId = prototypeCampaignType,
								  Event_Start_Time__c = DateTime.newInstance(2015, 4, 1, 14, 0, 0),
								  Venue__c = v.Id);
		insert cc;

		// Create a Prototype Job and Shifts for GA
		Id prototypeJobType =  [SELECT Id FROM RecordType 
										WHERE SObjectType = 'GW_Volunteers__Volunteer_Job__c' 
										AND DeveloperName='Volunteer_Job_Prototype'].Id;
		Id prototypeShiftType =  [SELECT Id FROM RecordType 
								WHERE SObjectType = 'GW_Volunteers__Volunteer_Shift__c' 
								AND DeveloperName='Volunteer_Shift_Prototype'].Id;
		GW_Volunteers__Volunteer_Job__c usher1 = new  GW_Volunteers__Volunteer_Job__c(Name='Usher',
											  GW_Volunteers__Campaign__c = c.Id,
											  GW_Volunteers__Description__c = 'Helps hand out programs',
											  GW_Volunteers__Display_on_Website__c = true,
											  GW_Volunteers__Inactive__c = false,
											  GW_Volunteers__Location_City__c = 'Seattle',
											  GW_Volunteers__Location_Information__c = 'No Parking',
											  GW_Volunteers__Location__c = 'WA',
											  GW_Volunteers__Location_Street__c = '155 Mercer St',
											  GW_Volunteers__Location_Zip_Postal_Code__c = '98109',
											  GW_Volunteers__Ongoing__c = false,
											  Volunteer_sees_show__c = false,
											  RecordTypeId = prototypeJobType);
		insert usher1;
		GW_Volunteers__Volunteer_Shift__c shift1 = new GW_Volunteers__Volunteer_Shift__c(
						GW_Volunteers__Duration__c = 2,
						GW_Volunteers__Desired_Number_of_Volunteers__c = 8,
						GW_Volunteers__Start_Date_Time__c = DateTime.newInstance(2015, 4, 1, 13, 0, 0),
						GW_Volunteers__Volunteer_Job__c = usher1.Id,
						RecordTypeId = prototypeShiftType);
		insert shift1;
		GW_Volunteers__Volunteer_Job__c usher2 = new  GW_Volunteers__Volunteer_Job__c(Name='Usher',
											  GW_Volunteers__Campaign__c = cc.Id,
											  GW_Volunteers__Description__c = 'Helps hand out programs',
											  GW_Volunteers__Display_on_Website__c = true,
											  GW_Volunteers__Inactive__c = false,
											  GW_Volunteers__Location_City__c = 'Seattle',
											  GW_Volunteers__Location_Information__c = 'No Parking',
											  GW_Volunteers__Location__c = 'WA',
											  GW_Volunteers__Location_Street__c = '155 Mercer St',
											  GW_Volunteers__Location_Zip_Postal_Code__c = '98109',
											  GW_Volunteers__Ongoing__c = false,
											  Volunteer_sees_show__c = false,
											  RecordTypeId = prototypeJobType);
		insert usher2;
		GW_Volunteers__Volunteer_Shift__c shift2 = new GW_Volunteers__Volunteer_Shift__c(
				GW_Volunteers__Duration__c = 2,
				GW_Volunteers__Desired_Number_of_Volunteers__c = 12,
				GW_Volunteers__Start_Date_Time__c = DateTime.newInstance(2015, 4, 1, 13, 0, 0),
				GW_Volunteers__Volunteer_Job__c = usher2.Id,
				RecordTypeId = prototypeShiftType);
		insert shift2;
		GW_Volunteers__Volunteer_Job__c door2 = new  GW_Volunteers__Volunteer_Job__c(Name='Door Attendant',
											  GW_Volunteers__Campaign__c = cc.Id,
											  GW_Volunteers__Description__c = 'Validates Tickets',
											  GW_Volunteers__Display_on_Website__c = true,
											  GW_Volunteers__Inactive__c = false,
											  GW_Volunteers__Location_City__c = 'Seattle',
											  GW_Volunteers__Location_Information__c = 'No Parking',
											  GW_Volunteers__Location__c = 'WA',
											  GW_Volunteers__Location_Street__c = '155 Mercer St',
											  GW_Volunteers__Location_Zip_Postal_Code__c = '98109',
											  GW_Volunteers__Ongoing__c = false,
											  Volunteer_sees_show__c = false,
											  RecordTypeId = prototypeJobType);
		insert door2;
		GW_Volunteers__Volunteer_Shift__c shift3 = new GW_Volunteers__Volunteer_Shift__c(
				GW_Volunteers__Duration__c = 3,
				GW_Volunteers__Desired_Number_of_Volunteers__c = 4,
				GW_Volunteers__Start_Date_Time__c = DateTime.newInstance(2015, 4, 1, 12, 30, 0),
				GW_Volunteers__Volunteer_Job__c = door2.Id,
				RecordTypeId = prototypeShiftType);
		insert shift3;
	}

}