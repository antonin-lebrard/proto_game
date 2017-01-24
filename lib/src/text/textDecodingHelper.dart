part of proto_game.text;


class IfText {
  StoredCondition condition;
  Text text;
  IfText(this.condition, this.text);
}

class ElseText {
  Text text;
  ElseText(this.text);
}

abstract class TextDecodingHelper {

  static final String _beginVariableOperator = r"${";
  static final String _endVariableOperator = "}";
  static final String _ifConditionOperator = "(if:";
  static final String _elseConditionOperator = "(else:)";
  static final String _endConditionOperator = ")";
  static final List<String> _conditionsOperators = ["(if:", "(else:"];
  static final String _beginConditionText = '[';
  static final String _endConditionText = ']';

  static decompose(String fullS, Function decodeGameVariable, Function addTextPart, Type eventType){
    String s = fullS.substring(0); // copy for error printing
    int idxCondition = s.indexOf(_ifConditionOperator);
    if (s.indexOf(_elseConditionOperator) != -1 && s.indexOf(_elseConditionOperator) < idxCondition) {
      Logger.log(new DecodingError(fullS, "no 'if' statement before else statement, will be included as text instead"));
    }
    while (idxCondition > -1) {
      _decodeTextAndGameVariables(s.substring(0, idxCondition), decodeGameVariable, addTextPart);
      s = s.substring(idxCondition + _ifConditionOperator.length);
      String condition = s.substring(0, s.indexOf(_endConditionOperator));
      StoredCondition conditionObj = new StoredCondition.fromString(null, condition);
      s = s.substring(s.indexOf(_beginConditionText) + _beginConditionText.length);
      String text = _decodeNestedText(s);
      if (text == null) {
        Logger.log(new DecodingError(fullS, "not closing 'if' statement by ')', will not parse it and the rest of"));
        return;
      }
      addTextPart(new IfText(conditionObj, new Text.fromString(text, eventType)));
      s = s.substring(text.length+1);
      int idxElseStatement = s.indexOf(_elseConditionOperator);
      idxCondition = s.indexOf(_ifConditionOperator);
      // else statement present
      if (idxElseStatement < idxCondition || (idxCondition == -1 && idxElseStatement > -1)) {
        _decodeTextAndGameVariables(s.substring(0, idxElseStatement), decodeGameVariable, addTextPart);
        s = s.substring(s.indexOf(_beginConditionText) + _beginConditionText.length);
        String text = _decodeNestedText(s);
        if (text == null) {
          Logger.log(new DecodingError(fullS, "not closing 'else' statement by ), will not parse it and the rest of"));
          return;
        }
        try {
          addTextPart(new ElseText(new Text.fromString(text, eventType)));
        } on NoIfBeforeElseException {
          Logger.log(new DecodingError(fullS, "no 'if' statement before else statement, will not parse else statement"));
        }
        s = s.substring(text.length+1);
        idxCondition = s.indexOf(_ifConditionOperator);
      }
    }
    _decodeTextAndGameVariables(s, decodeGameVariable, addTextPart);
  }


  static String _decodeNestedText(String s){
    String nestedText = "";
    int countOpeningBracket = 0;
    StringScanner scanner = new StringScanner(s);
    while (!scanner.isDone){
      int char = scanner.readChar();
      if (char == $lbracket)
        countOpeningBracket++;
      else if (char == $rbracket && countOpeningBracket > 0)
        countOpeningBracket--;
      else if (char == $rbracket){
        return nestedText;
      }
      nestedText += new String.fromCharCode(char);
    }
    return null;
  }

  static _decodeTextAndGameVariables(String s, Function decodeGameVariable, Function addTextPart){
    bool variableMode = false;
    String currentTextPart = "";
    StringScanner scanner = new StringScanner(s);
    while (!scanner.isDone){
      int char = scanner.readChar();
      if (!variableMode && char == $dollar && scanner.peekChar() == $open_brace){
        // found '${'
        if (currentTextPart.length > 0)
          addTextPart(currentTextPart);
        currentTextPart = "";
        scanner.readChar(); // to skip '{'
        variableMode = true;
      } else if (variableMode && char == $close_brace) {
        // found '}'
        addTextPart(decodeGameVariable(currentTextPart));
        currentTextPart = "";
        variableMode = false;
      } else {
        currentTextPart += new String.fromCharCode(char);
      }
    }
    if (currentTextPart.length > 0)
      addTextPart(currentTextPart);
  }

}