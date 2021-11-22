@IsTest(SeeAllData = false)
private with sharing class CaseTriggerHandlerTest {
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

    @isTest
    static void maxLengthWhenSubjectAndDecriptionExist() {
        Integer extraSymbolsPlusBlankSpace = 3; // blank space between Subject and Description give us 1 "extraSymbol" and another 2 "extraSymbols" are square brackets where the subject is located

        Case newCase = new Case(
            OwnerId = getTestUser().Id,
            Subject = getExampleText(40),
            Description = getExampleText(130)
        );

        Test.startTest();
        insert newCase;
        Test.stopTest();

        Case testCase = [SELECT Short_Summary__c FROM Case WHERE OwnerId =: getTestUser().Id];
        Integer lengthOfShortSummary = testCase.Short_Summary__c.length();
        Integer maxLengthTotalToCheck = maxLenghtSubject + maxLenghtDescription + extraSymbolsPlusBlankSpace;

        System.assertEquals(maxLengthTotalToCheck, lengthOfShortSummary, 'Error in maxLengthWhenSubjectAndDecriptionExist() - max length should be ' + (maxLengthTotalToCheck));
    }

    @isTest
    static void lengthWhenDescriptionNotExist() {
        Integer extraSymbolsPlusBlankSpace = 2; // 2 "extraSymbols" are square brackets where the subject is located, when Description not exist it wont add blank space

        Case newCase = new Case(
            OwnerId = getTestUser().Id,
            Subject = getExampleText(15)
        );

        Test.startTest();
        insert newCase;
        Test.stopTest();

        Case testCase = [SELECT Short_Summary__c, Subject FROM Case WHERE OwnerId =: getTestUser().Id];
        Integer lengthOfShortSummary = testCase.Short_Summary__c.length();
        Integer lengthOfSubject = testCase.Subject.length();

        System.assertNotEquals(maxLenghtSubject + extraSymbolsPlusBlankSpace, lengthOfShortSummary, 'Error in lengthWhenDescriptionNotExist() - sample Subject should be shorter than ' + maxLenghtSubject);
        System.assertEquals(lengthOfSubject + extraSymbolsPlusBlankSpace, lengthOfShortSummary, 'Error in lengthWhenDescriptionNotExist() - short summary should be the same length as sample subject');
    }

    @isTest
    static void lengthWhenSubjectNotExist() {
        Integer extraSymbolsPlusBlankSpace = 0; // blank space between Subject and Description give us 1 "extraSymbol", but when Subject not exist it wont add it

        Case newCase = new Case(
            OwnerId = getTestUser().Id,
            Description = getExampleText(30)
        );

        Test.startTest();
        insert newCase;
        Test.stopTest();

        Case testCase = [SELECT Short_Summary__c, Description FROM Case WHERE OwnerId =: getTestUser().Id];
        Integer lengthOfShortSummary = testCase.Short_Summary__c.length();
        Integer lengthOfDescription = testCase.Description.length();

        System.assertNotEquals(maxLenghtDescription + extraSymbolsPlusBlankSpace, lengthOfShortSummary, 'Error in lengthWhenSubjectNotExist() - sample Description should be shorter than ' + maxLenghtDescription);
        System.assertEquals(lengthOfDescription + extraSymbolsPlusBlankSpace, lengthOfShortSummary, 'Error in lengthWhenSubjectNotExist() - short summary should be the same length as sample description');
    }

    @isTest
    static void shouldCreateContactAndAccountWhenDataWithEmailWasNotFound() {
        Case newCase = new Case(
            OwnerId = getTestUser().Id,
            SuppliedEmail = getTestUser().Email,
            Description = getExampleText(30)
        );

        Test.startTest();
        insert newCase;
        Test.stopTest();

        Case testCase = [SELECT AccountId, ContactId FROM Case WHERE OwnerId =: getTestUser().Id];
        System.assertNotEquals(null, testCase.AccountId, 'Error in shouldCreateContactAndAccountWhenDataWithEmailWasNotFound() - should create dummy account');
        System.assertNotEquals(null, testCase.ContactId, 'Error in shouldCreateContactAndAccountWhenDataWithEmailWasNotFound() - should create dummy contact');
    }   

    @isTest
    static void shouldNotCreateAdditionalContactAndAccountWhenDataWithEmailWasFound() {
        Account newAccount = new Account(
            Name = getTestUser().FirstName
        );
        insert newAccount;    

        Contact newContact = new Contact(
            AccountId = newAccount.Id,
            Email = getTestUser().Email,
            LastName = getTestUser().FirstName
        );
        insert newContact;

        Case newCase = new Case(
            OwnerId = getTestUser().Id,
            SuppliedEmail = getTestUser().Email,
            Description = getExampleText(30)
        );

        Test.startTest();
        insert newCase;
        Test.stopTest();

        List<Contact> testContact = [SELECT Id FROM Contact WHERE Email =: getTestUser().Email];
        System.assertEquals(testContact.size(), 1, 'Error in shouldNotCreateAdditionalContactAndAccountWhenDataWithEmailWasFound() - should not create another contact');
    }

    static User getTestUser() {
        return [SELECT Id, Email, FirstName FROM User WHERE FirstName = 'Test' LIMIT 1];
    }

    static String getExampleText(Integer length) {
        List<String> text = new List<String>{'t', 'e', 's', 't'};
        String result = '';
        for(Integer i = 0; i <= length - 1; i++) {
            if(i >= text.size() - 1) {
                result += text[Math.Mod(i, text.size())];
            } else {
                result += text[i];
            }
        }
        return result;
    }
}