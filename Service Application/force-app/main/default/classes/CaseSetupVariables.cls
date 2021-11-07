public class CaseSetupVariables {
	private static final Integer MAXIMAL_TITLE_LENGTH_OF_SHORT_SUMMARY = 35;
    private static final Integer MAXIMAL_DESCRIPTION_LENGTH_OF_SHORT_SUMMARY = 120;
    
    public Integer getMaxLengthOfTitleForShortSummary() {
        return MAXIMAL_TITLE_LENGTH_OF_SHORT_SUMMARY;
    }
    
    public Integer getMaxLengthOfDescriptionForShortSummary() {
        return MAXIMAL_DESCRIPTION_LENGTH_OF_SHORT_SUMMARY;
    }
}