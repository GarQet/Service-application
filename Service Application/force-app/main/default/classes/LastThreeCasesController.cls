public class LastThreeCasesController {  
    @AuraEnabled
    public static List<Case> getUserCasesData(Id userId, Integer limitOfRecords) {
        List<Case> cases = [
            SELECT Id, CaseNumber, Status, Description, CreatedDate
            FROM Case
            WHERE OwnerId = :userId
            ORDER BY CreatedDate DESC
            LIMIT :limitOfRecords
        ];
        return cases;
    }
}