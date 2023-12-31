// The idea here is finding the newly updated Contact, which has the Active field updated through Approval Process, and deleted Contact
trigger UpdateTotalContacts on Contact (after update, after delete) {
    // Map of Account Id and the diff of Total Contact
    Map<Id, Integer> accountTotalContacts = new Map<Id, Integer>();
    
    // If the contact is deleted
    if (Trigger.isDelete) {
        // Loop through old records
        for (Contact contact: Trigger.old) {
            // Skip if the contact is inactive
            if (contact.Active__c != true) continue;

            if (accountTotalContacts.containsKey(contact.AccountId)) {
                accountTotalContacts.put(contact.AccountId, accountTotalContacts.get(contact.AccountId) - 1);
            }
            else {
                accountTotalContacts.put(contact.AccountId, -1);
            }
        }
    }
    else if (Trigger.isUpdate) {
        // Loop through the updated contacts
        for (Contact contact: Trigger.new) {
            Contact oldContact = Trigger.oldMap.get(contact.Id);

            // Skip if Active field is unchanged
            if (contact.Active__c == oldContact.Active__c) continue;

            // Increase if Active field is set to true and decrease if it set to false
            Integer countChange = contact.Active__c == true ? 1 : -1;

            if (accountTotalContacts.containsKey(contact.AccountId)) {
                accountTotalContacts.put(contact.AccountId, accountTotalContacts.get(contact.AccountId) + countChange);
            }
            else {
                accountTotalContacts.put(contact.AccountId, countChange);
            }
        }
    }

    // Stops the trigger if there are no accounts to update.
    if (accountTotalContacts.isEmpty()) return;
    
    List<Account> accountsToUpdate = new List<Account>();

    for (Account acc : [SELECT Id, Total_Contact__c FROM Account WHERE Id IN :accountTotalContacts.keySet()]) {
        acc.Total_Contact__c += accountTotalContacts.get(acc.Id);
        accountsToUpdate.add(acc);
    }
    
    update accountsToUpdate;
}
