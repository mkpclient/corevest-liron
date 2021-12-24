@isTest
private class ConvertCurrencyToWordsTest {
   
    static TestMethod void testMethod1(){
        test.startTest();
        ConvertCurrencyToWords.convert_nn(100);
        ConvertCurrencyToWords.convert_nnn(100);
        ConvertCurrencyToWords.english_number(999);
        ConvertCurrencyToWords.english_number(1000);
        ConvertCurrencyToWords.getCurrencyInWords(100.10,'','','','part1','UpperCase');
        ConvertCurrencyToWords.getPercentageInWords(100.10,'','','','part1','UpperCase');
        ConvertCurrencyToWords.getCurrencyInWords(100,'','','','part2','LowerCase');
        ConvertCurrencyToWords.getPercentageInWords(100,'','','','part2','LowerCase');
        test.stopTest();
    }
}