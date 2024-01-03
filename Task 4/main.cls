@RestResource(urlMapping='/contacts/batch-update/')
global with sharing class BatchUpdateContactService {

  global class ApiResponse {
    public Boolean success;
    public String message;
    public Object data;

    public ApiResponse(Boolean success, String message) {
      this.success = success;
      this.message = message;
      this.data = null;
    }

    public ApiResponse(Boolean success, String message, Object data) {
      this.success = success;
      this.message = message;
      this.data = data;
    }
  }

  global class ContactDto {
    public String Id;
    public String FirstName;
    public String LastName;
  }

  @HttpPost
  global static String updateContacts(List<ContactDto> data) {
    if (data == null || data.isEmpty()) {
      return '{"error": "No contacts provided"}';
    }

    List<Contact> updatedContacts = new List<Contact>();
    
    // Validate and update each Contact
    for (ContactDto contact : data) {
      if (contact.Id == null) {
        ApiResponse response = new ApiResponse(false, 'Contact Id is required.');
        return JSON.serialize(response);
      }

      // Check if the Contact exists
      Contact existContact = [SELECT Id FROM Contact WHERE Id = :contact.Id LIMIT 1];
      if (existContact == null) {
        ApiResponse response = new ApiResponse(false, 'Contact with Id "' + contact.Id + '" not found!');
        return JSON.serialize(response);
      }

      existContact.FirstName = contact.FirstName;
      existContact.LastName = contact.LastName;
      
      updatedContacts.add(existContact);
    }

    try {
      update updatedContacts;

      ApiResponse response = new ApiResponse(true, 'Contacts updated successfully');
      return JSON.serialize(response);
    } catch (Exception e) {
      ApiResponse response = new ApiResponse(false, e.getMessage());
      return JSON.serialize(response);
    }
  }
}
