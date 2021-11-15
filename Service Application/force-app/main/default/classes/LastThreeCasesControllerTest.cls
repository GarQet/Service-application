@isTest(SeeAllData = false)
private with sharing class LastThreeCasesControllerTest {
    private static Integer AMOUNT_OF_CASES = 3;
    
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
        for(Integer i = 1; i <= AMOUNT_OF_CASES; i++) {
            newCases.add(new Case(
                OwnerId = newUser.Id
            ));
        }
        insert newCases;
    }
    
    @isTest
    static void getThreeLatestCases() {        
        Test.startTest();
        List<Case> results = LastThreeCasesController.getUserCasesData(getTestUser().Id, AMOUNT_OF_CASES);
        Test.stopTest();
        
        System.assertEquals(AMOUNT_OF_CASES, results.size(), 'Error in getThreeLatestCases() - ' + AMOUNT_OF_CASES + ' cases records should be returned');
    }
    
	@isTest
    static void getStatusFromThreeLatestCases() {
        List<Case> testCase = [SELECT Id, Status FROM Case WHERE OwnerId =: getTestUser().Id];
        
        System.assertEquals(AMOUNT_OF_CASES, testCase.size());
        
        List<Case> results = LastThreeCasesController.getUserCasesData(getTestUser().Id, testCase.size());
        for(Case cases : results) {
            System.assertEquals(Constants.CASE_STATUS_DEFAULT, cases.Status, 'Error in getStatusFromThreeLatestCases() - cases should have status New');
        }
        
        for (Case cases : testCase) {
            cases.Status = Constants.CASE_STATUS_WORKING;
        }
        
       	Test.startTest(); 
        update testCase;
        Test.stopTest();
        
        results = LastThreeCasesController.getUserCasesData(getTestUser().Id, testCase.size());
        for(Case cases : results) {
        	System.assertEquals(Constants.CASE_STATUS_WORKING, cases.Status, 'Error in getStatusFromThreeLatestCases() - Cases should have status Working');
        }
    }
    
    static User getTestUser() {
        return [SELECT Id FROM User WHERE FirstName = 'Test' LIMIT 1];
    }    
}