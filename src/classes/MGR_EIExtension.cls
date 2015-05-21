public with sharing class MGR_EIExtension {

	private final sObject mysObject;


    public MGR_EIExtension(ApexPages.StandardController stdController) {
        this.mysObject = (sObject)stdController.getRecord();
    }

    public List<PatronTicket__EventInstance__c> getEventInstances() {
        return [Select Name,Roster_Link__c 
                FROM PatronTicket__EventInstance__c 
                WHERE PatronTicket__TicketableEvent__c =: this.mysObject.Id
                ORDER BY PatronTicket__InstanceDate__c];
    }
}