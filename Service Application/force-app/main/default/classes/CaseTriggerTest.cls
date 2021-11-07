@isTest
private with sharing class CaseTriggerTest {   
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
    
    @isTest
    static void checkMaxLengthOfShortSummary() {
        User testUser = [SELECT Id FROM User WHERE FirstName = 'Test'];
        Integer extraSymbolsPlusBlankSpace = 3; // Trigger creating short summary like this '[Subject]' + ' Description'
        									    // two symbols: '[' and ']', one blank space ' ', total 3 elements.
        CaseSetupVariables getInfo = new CaseSetupVariables();
        Integer maxLenghtTitle = getInfo.getMaxLengthOfTitleForShortSummary();
        Integer maxLenghtDescription = getInfo.getMaxLengthOfDescriptionForShortSummary();
        System.assertEquals(35, maxLenghtTitle);
        System.assertEquals(120, maxLenghtDescription);
        
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
        
        System.assertEquals(maxLenghtTitle + maxLenghtDescription + extraSymbolsPlusBlankSpace, caseShortSummaryLength);
    }
    
    @isTest
    static void titleShorterThanMax() {
        User testUser = [SELECT Id FROM User WHERE FirstName = 'Test'];
        Integer extraSymbolsPlusBlankSpace = 2; // Trigger creating short summary like this '[Subject]' + ' Description'
        									    // two symbols: '[' and ']', blank space is added in Description ' ', total 2 elements.
        CaseSetupVariables getInfo = new CaseSetupVariables();
        Integer maxLenghtTitle = getInfo.getMaxLengthOfTitleForShortSummary();
        System.assertEquals(35, maxLenghtTitle);
        
        Case newCase = new Case(
        	OwnerId = testUser.Id,
            Subject = 'Test subject' // 12 chars
        );
        Test.startTest();
        insert newCase;
        Test.stopTest();
        
        Case testCase = [SELECT Short_Summary__c, Subject FROM Case WHERE OwnerId =: testUser.Id];
        Integer caseShortSummaryLength = testCase.Short_Summary__c.length();
        Integer caseTitleLength = testCase.Subject.length();
        
        System.assertNotEquals(maxLenghtTitle + extraSymbolsPlusBlankSpace, caseShortSummaryLength);
        System.assertEquals(caseTitleLength + extraSymbolsPlusBlankSpace, caseShortSummaryLength);
    }

    @isTest
    static void descriptionShorterThanMax() {
        User testUser = [SELECT Id FROM User WHERE FirstName = 'Test'];
        Integer extraSymbolsPlusBlankSpace = 0; // Trigger creating short summary like this '[Subject]' + ' Description'
        									    // Should count only blank space ' ', but it wont, so in total 0 element.
        CaseSetupVariables getInfo = new CaseSetupVariables();
        Integer maxLenghtDescription = getInfo.getMaxLengthOfDescriptionForShortSummary();
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
        
        System.assertNotEquals(maxLenghtDescription + extraSymbolsPlusBlankSpace, caseShortSummaryLength);
        System.assertEquals(caseDescriptionLength + extraSymbolsPlusBlankSpace, caseShortSummaryLength);
    }    
}