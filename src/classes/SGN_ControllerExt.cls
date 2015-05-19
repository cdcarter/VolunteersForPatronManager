public with sharing class SGN_ControllerExt {

	private final PatronTicket__EventInstance__c ei;

    public SGN_ControllerExt(ApexPages.StandardController stdController) {
        this.ei = (PatronTicket__EventInstance__c)stdController.getRecord();
    }

    public List<GW_Volunteers__Volunteer_Hours__c> getHours() {
        List<GW_Volunteers__Volunteer_Hours__c> hours = [SELECT Id,
                                            GW_Volunteers__Number_of_Volunteers__c,
                                            GW_Volunteers__Contact__r.FirstName, 
                                            GW_Volunteers__Volunteer_Job__r.Name,
                                            GW_Volunteers__Contact__r.LastName FROM GW_Volunteers__Volunteer_Hours__c
                                            WHERE GW_Volunteers__Volunteer_Shift__r.EventInstance__c =: this.ei.Id];
        return hours;
    }
}