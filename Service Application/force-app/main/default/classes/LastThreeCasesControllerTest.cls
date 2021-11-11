@isTest
private with sharing class LastThreeCasesControllerTest {
	@TestSetup
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
        
        List<Case> newCases = new List<Case>();
        newCases.add(new Case(
        	OwnerId = newUser.Id
        ));
        newCases.add(new Case(
        	OwnerId = newUser.Id
        ));
        newCases.add(new Case(
        	OwnerId = newUser.Id
        ));
        insert newCases;
    }
    
    @isTest
    static void getThreeLatestCases() {
        User testUser = [SELECT Id FROM User WHERE FirstName = 'Test' LIMIT 1];
        List<Case> results = LastThreeCasesController.getUserCasesData(testUser.Id, Constants.AMOUNT_OF_CASES);
        System.assertEquals(Constants.AMOUNT_OF_CASES, results.size());
    }
    
	@isTest
    static void getStatusFromThreeLatestCases() {
        User testUser = [SELECT Id FROM User WHERE FirstName = 'Test' LIMIT 1];
        List<Case> testTotalCases = [SELECT Id FROM Case WHERE OwnerId =: testUser.Id];
        
        System.assertEquals(Constants.AMOUNT_OF_CASES, testTotalCases.size());
        
        List<Case> results = LastThreeCasesController.getUserCasesData(testUser.Id, testTotalCases.size());
        //Verifying if all User cases has assigned default Status name
        for(Case cases : results) {
            System.assertEquals(Constants.CASE_STATUS_DEFAULT, cases.Status);
        }
        
        //Seeting Status name
        List<Case> testCase = [SELECT Status FROM Case WHERE OwnerId =: testUser.Id];
        for (Case cases : testCase) {
            cases.Status = Constants.CASE_STATUS_WORKING;
        }
        
       	Test.startTest(); 
        update testCase;
        Test.stopTest();
        
        //Checking Status name
        results = LastThreeCasesController.getUserCasesData(testUser.Id, testTotalCases.size());
        for(Case cases : results) {
        	System.assertEquals(Constants.CASE_STATUS_WORKING, cases.Status);
        }
    }
}