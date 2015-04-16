public class eiInstance {
	public PatronTicket__EventInstance__c eventInstance {get;set;}
	public String campaign {get;set;}
	public Boolean build {get;set;}
	public List<SelectOption> options {get; set;}
	public eiInstance(PatronTicket__EventInstance__c ei) {
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