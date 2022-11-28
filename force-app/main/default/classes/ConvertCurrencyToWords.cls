public with sharing class ConvertCurrencyToWords {
  static String[] to_19 = new List<string>{
    'Zero',
    'One',
    'Two',
    'Three',
    'Four',
    'Five',
    'Six',
    'Seven',
    'Eight',
    'Nine',
    'Ten',
    'Eleven',
    'Twelve',
    'Thirteen',
    'Fourteen',
    'Fifteen',
    'Sixteen',
    'Seventeen',
    'Eighteen',
    'Nineteen'
  };
  static String[] tens = new List<string>{
    'Twenty',
    'Thirty',
    'Forty',
    'Fifty',
    'Sixty',
    'Seventy',
    'Eighty',
    'Ninety'
  };

  static string[] denom = new List<string>{
    '',
    'Thousand',
    'Million',
    'Billion',
    'trillion',
    'quadrillion',
    'quintillion',
    'sixtillion',
    'septillion',
    'octillion',
    'nonillion',
    'decillion',
    'undecillion',
    'duodecillion',
    'tredecillion',
    'quattuordecillion',
    'sixdecillion',
    'septendecillion',
    'octodecillion',
    'novemdecillion',
    'vigintillion'
  };
  // convert a value < 100 to English.
  public static string convert_nn(integer val) {
    if (val < 20)
      return to_19[val];
    if (val == 100)
      return 'One Hundred';
    for (integer v = 0; v < tens.size(); v++) {
      String dcap = tens[v];
      integer dval = 20 + 10 * v;
      if (dval + 10 > val) {
        if (Math.Mod(val, 10) != 0)
          return dcap + '-' + to_19[Math.Mod(val, 10)];
        return dcap;
      }
    }
    return 'Should never get here, less than 100 failure';
  }
  // convert a value < 1000 to english, special cased because it is the level that kicks
  // off the < 100 special case. The rest are more general. This also allows you to
  // get strings in the form of "forty-five hundred" if called directly.
  public static String convert_nnn(integer val) {
    string word = '';
    integer rem = val / 100;
    integer mod = Math.mod(val, 100);
    if (rem > 0) {
      word = to_19[rem] + ' Hundred';
      if (mod > 0) {
        word += ' ';
      }
    }
    if (mod > 0) {
      word += convert_nn(mod);
    }
    return word;
  }
  public static String english_number(long val) {
    if (val < 100) {
      return convert_nn(val.intValue());
    }
    if (val < 1000) {
      return convert_nnn(val.intValue());
    }
    for (integer v = 0; v < denom.size(); v++) {
      integer didx = v - 1;
      integer dval = (integer) Math.pow(1000, v);
      if (dval > val) {
        integer mod = (integer) Math.pow(1000, didx);
        integer l = (integer) val / mod;
        integer r = (integer) val - (l * mod);
        String ret = convert_nnn(l) + ' ' + denom[didx];
        if (r > 0) {
          ret += ', ' + english_number(r);
        }
        return ret;
      }
    }
    return 'Should never get here, bottomed out in english_number';
  }

  public static String getCurrencyInWords(
    Decimal amount,
    String unit1,
    String unit2,
    String unitSeprator,
    String returnType,
    String letterCaseType
  ) {
    String finalAmountInWord = '';
    string part1InWords;
    string part2InWords;

    String amountString = String.valueOf(amount);
    if (amountString.contains('.')) {
      string part1 = amountString.split('\\.')[0];
      part1InWords = ConvertCurrencyToWords.english_number(long.valueOf(part1));
      part1InWords = part1InWords.remove(',') + unit1;
      System.debug('part1InWords----> ' + part1InWords);
      finalAmountInWord = part1InWords;

      string part2 = amountString.split('\\.')[1];
      if (Integer.ValueOf(part2) > 0) {
        part2InWords = ConvertCurrencyToWords.english_number(
          long.valueOf(part2)
        );
        part2InWords = part2InWords.remove(',') + ' ' + unit2;
        System.debug('part2InWords----> ' + part2InWords);
        finalAmountInWord += ' ' + unitSeprator + ' ' + part2InWords;
      }
    } else {
      string amountInWords = ConvertCurrencyToWords.english_number(
        amount.longValue()
      );
      finalAmountInWord = amountInWords.remove(',') + unit1;
      System.debug('finalAmountInWord----> ' + finalAmountInWord);
    }
    System.debug('finalAmountInWord----> ' + finalAmountInWord);

    if (letterCaseType == 'UpperCase') {
      part1InWords = part1InWords != null
        ? part1InWords.toUpperCase()
        : part1InWords;
      part2InWords = part2InWords != null
        ? part2InWords.toUpperCase()
        : part2InWords;
      finalAmountInWord = finalAmountInWord != null
        ? finalAmountInWord.toUpperCase()
        : finalAmountInWord;
    } else if (letterCaseType == 'LowerCase') {
      part1InWords = part1InWords != null
        ? part1InWords.toLowerCase()
        : part1InWords;
      part2InWords = part2InWords != null
        ? part2InWords.toLowerCase()
        : part2InWords;
      finalAmountInWord = finalAmountInWord != null
        ? finalAmountInWord.toLowerCase()
        : finalAmountInWord;
    }

    if (returnType == 'part1') {
      return part1InWords;
    } else if (returnType == 'part2') {
      return part2InWords;
    } else {
      return finalAmountInWord;
    }
  }

  public static String getPercentageInWords(
    Decimal amount,
    String unit1,
    String unit2,
    String unitSeprator,
    String returnType,
    String letterCaseType
  ) {
    String finalAmountInWord = '';
    string part1InWords;
    string part2InWords;

    String amountString = String.valueOf(amount);
    if (amountString.contains('.')) {
      string part1 = amountString.split('\\.')[0];
      part1InWords = ConvertCurrencyToWords.english_number(long.valueOf(part1));
      part1InWords = part1InWords.remove(',') + unit1;
      System.debug('part1InWords----> ' + part1InWords);
      finalAmountInWord = part1InWords;

      string part2 = amountString.split('\\.')[1];
      if (Integer.ValueOf(part2) > 0) {
        //as this is decimal point so display digits after decimal as seven five instead of seventy five
        if (part2.length() > 1) {
          if (part2.length() > 2) {
            part2InWords =
              ConvertCurrencyToWords.english_number(
                long.valueOf(part2.substring(0, 1))
              ) +
              ' ' +
              ConvertCurrencyToWords.english_number(
                long.valueOf(part2.substring(1, 2))
              );
          }
        } else {
          part2InWords = ConvertCurrencyToWords.english_number(
            long.valueOf(part2)
          );
        }
        //   part2InWords = part2InWords.remove(',')+' '+unit2;
        finalAmountInWord += ' ' + unitSeprator + ' ' + part2InWords;
      }
    } else {
      string amountInWords = ConvertCurrencyToWords.english_number(
        amount.longValue()
      );
      finalAmountInWord = amountInWords.remove(',') + unit1;
    }
    System.debug('finalAmountInWord----> ' + finalAmountInWord);

    if (letterCaseType == 'UpperCase') {
      part1InWords = part1InWords != null
        ? part1InWords.toUpperCase()
        : part1InWords;
      part2InWords = part2InWords != null
        ? part2InWords.toUpperCase()
        : part2InWords;
      finalAmountInWord = finalAmountInWord != null
        ? finalAmountInWord.toUpperCase()
        : finalAmountInWord;
    } else if (letterCaseType == 'LowerCase') {
      part1InWords = part1InWords != null
        ? part1InWords.toLowerCase()
        : part1InWords;
      part2InWords = part2InWords != null
        ? part2InWords.toLowerCase()
        : part2InWords;
      finalAmountInWord = finalAmountInWord != null
        ? finalAmountInWord.toLowerCase()
        : finalAmountInWord;
    }

    if (returnType == 'part1') {
      return part1InWords;
    } else if (returnType == 'part2') {
      return part2InWords;
    } else {
      return finalAmountInWord;
    }
  }
}