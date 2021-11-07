trigger CaseTrigger on Case (before insert) {
    List<Case> newCases = (List<Case>) Trigger.new;
    CaseSetupVariables getInfo = new CaseSetupVariables();
    Integer maxLenghtTitle = getInfo.getMaxLengthOfTitleForShortSummary();
    Integer maxLenghtDescription = getInfo.getMaxLengthOfDescriptionForShortSummary();
    
    if(Trigger.isBefore) {
        if(Trigger.isInsert) {
            List<Case> cases = [SELECT Id, Subject, Description, Short_Summary__c FROM Case WHERE Id IN :newCases];
            for (Case actualCase: newCases) {
                String shortcut = '';
                if(actualCase.Subject != null) {
                	Integer titleLenght = actualCase.Subject.length();   
                    if(titleLenght > maxLenghtTitle) {
                        shortcut = '[' + actualCase.Subject.substring(0, maxLenghtTitle - 3) + '...]';
                    } else {
                        shortcut = '[' + actualCase.Subject + ']';
                    }
                }
                if(actualCase.Description != null) {
                    Integer descLenght = actualCase.Description.length();
                    if(descLenght > maxLenghtDescription) {
                        shortcut = shortcut + ' ' + actualCase.Description.substring(0, maxLenghtDescription - 3) + '...';
                    } else {
                        shortcut = shortcut + ' ' + actualCase.Description;
                    }               
                }
                actualCase.Short_Summary__c = shortcut;
            }
            update cases;
        }        
    }
}