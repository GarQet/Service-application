@isTest
private with sharing class CaseTriggerTest {  
    static Integer maxLenghtSubject = Constants.MAXIMAL_SUBJECT_LENGTH_OF_SHORT_SUMMARY;
    static Integer maxLenghtDescription = Constants.MAXIMAL_DESCRIPTION_LENGTH_OF_SHORT_SUMMARY;
    
	@testSetup
    static void setup() {
        Profile profile = [SELECT Id FROM Profile WHERE Name='Standard User'];
        User newUser = new User(
            FirstName = 'Test',
            LastName = 'User',
            Alias = 'TUser',
            Email = 'testuserforcases@example.com',
            Username = 'testuserforcases@example.com',
            CommunityNickname = 'TUser',
            TimeZoneSidKey = 'Europe/Warsaw',
            LocaleSidKey = 'pl',
            EmailEncodingKey = 'UTF-8',
            ProfileId = profile.Id,
            LanguageLocaleKey = 'en_US'
        );
        insert newUser;
    }
    
    /*
    Trigger creating short summary like this '[Subject]' + ' Description'
    If Subject is longer than 35 chars, Trigger should cut the String to 32 chars and add three dots
    If Description is longer than 120 chars, Trigger should cut the String to 117 chars and add three dots
    For example: If both variables exist the total length of short summary will be always longer for 3 chars (look at first line od this comment)
    																					- blank space, and two special symbols [ and ] = 3 chars
	*/
    
    @isTest
    static void checkMaxLengthOfShortSummary() {
        User testUser = [SELECT Id FROM User WHERE FirstName = 'Test'];
        Integer extraSymbolsPlusBlankSpace = 3; // blank space, and two special symbols [ and ] = 3 chars
        System.assertEquals(35, maxLenghtSubject);
        System.assertEquals(120, maxLenghtDescription);
        
        // Subject = 39 chars, Description = 128 chars, Total = 167 chars
        Case newCase = new Case(
        	OwnerId = testUser.Id,
            Subject = 'Test subject to test the maximum length',
            Description = 'Test description to test if the Trigger will correcly shorten the proper max length of Subject and Description to 120 + 35 = 155'
        );
        
        Test.startTest();
        insert newCase;
        Test.stopTest();
        
        Case testCase = [SELECT Short_Summary__c FROM Case WHERE OwnerId =: testUser.Id];
        Integer caseShortSummaryLength = testCase.Short_Summary__c.length();
        
        System.assertEquals(maxLenghtSubject + maxLenghtDescription + extraSymbolsPlusBlankSpace, caseShortSummaryLength);
    }
    
    @isTest
    static void subjectShorterThanMax() {
        User testUser = [SELECT Id FROM User WHERE FirstName = 'Test'];
        Integer extraSymbolsPlusBlankSpace = 2; // two symbols: '[' and ']', blank space would be added in Description which not exist in this test, total 2 elements.
        System.assertEquals(35, maxLenghtSubject);
        
        Case newCase = new Case(
        	OwnerId = testUser.Id,
            Subject = 'Test subject' // 12 chars
        );
        Test.startTest();
        insert newCase;
        Test.stopTest();
        
        Case testCase = [SELECT Short_Summary__c, Subject FROM Case WHERE OwnerId =: testUser.Id];
        Integer caseShortSummaryLength = testCase.Short_Summary__c.length();
        Integer caseSubjectLength = testCase.Subject.length();
        String caseShortSummary = testCase.Short_Summary__c;
        
		// Proof that subject has 12 chars        
        System.assertEquals(12, caseSubjectLength);
        System.assertEquals('[Test subject]', caseShortSummary);
        
        //Below assert: 35 + 2 =! 14 (12 Subject lenght + 2 extra sybols [])
        System.assertNotEquals(maxLenghtSubject + extraSymbolsPlusBlankSpace, caseShortSummaryLength);
        //Below assert: 12 + 2 = 14
        System.assertEquals(caseSubjectLength + extraSymbolsPlusBlankSpace, caseShortSummaryLength);
    }

    @isTest
    static void descriptionShorterThanMax() {
        User testUser = [SELECT Id FROM User WHERE FirstName = 'Test'];
        Integer extraSymbolsPlusBlankSpace = 0; // Should count only blank space ' ', but it won't, so in total 0 element.
        System.assertEquals(120, maxLenghtDescription);
        
        Case newCase = new Case(
        	OwnerId = testUser.Id,
            Description = 'Test description' // 16 chars
        );
        
        Test.startTest();
        insert newCase;
        Test.stopTest();
        
        Case testCase = [SELECT Short_Summary__c, Description FROM Case WHERE OwnerId =: testUser.Id];
        Integer caseShortSummaryLength = testCase.Short_Summary__c.length();
        Integer caseDescriptionLength = testCase.Description.length();
        String caseShortSummary = testCase.Short_Summary__c;
        
        // Proof that description has 16 chars
        System.assertEquals(16, caseDescriptionLength);
        System.assertEquals('Test description', caseShortSummary); 
        
        //Below assert: 120 + 0 =! 16 (TRUE)
        System.assertNotEquals(maxLenghtDescription + extraSymbolsPlusBlankSpace, caseShortSummaryLength);
        //Below assert: 16 + 0 = 16 (TRUE)
        System.assertEquals(caseDescriptionLength + extraSymbolsPlusBlankSpace, caseShortSummaryLength);
    }    
}