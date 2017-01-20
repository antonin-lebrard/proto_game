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

  static decompose(String s, Function addTextPart){
    int idxCondition = s.indexOf(_ifConditionOperator);
    if (s.indexOf(_elseConditionOperator) < idxCondition) {
      print("no 'if' statement before else statement, will be included as text instead :");
      print(s);
    }
    while (idxCondition > -1) {
      _decodeTextAndGameVariables(s.substring(0, idxCondition), addTextPart);
      s = s.substring(idxCondition + _ifConditionOperator.length);
      String condition = s.substring(0, s.indexOf(_endConditionOperator));
      StoredCondition conditionObj = new StoredCondition.fromString(null, condition);
      s = s.substring(s.indexOf(_beginConditionText) + _beginConditionText.length);
      String text = _decodeNestedText(s);
      if (text == null) {
        print("not closing 'if' statement, will not parse it and the rest of $s");
        return;
      }
      addTextPart(new IfText(conditionObj, new Text.fromString(text)));
      s = s.substring(text.length+1);
      int idxElseStatement = s.indexOf(_elseConditionOperator);
      idxCondition = s.indexOf(_ifConditionOperator);
      // else statement present
      if (idxElseStatement < idxCondition || (idxCondition == -1 && idxElseStatement > -1)) {
        _decodeTextAndGameVariables(s.substring(0, idxElseStatement), addTextPart);
        s = s.substring(s.indexOf(_beginConditionText) + _beginConditionText.length);
        String text = _decodeNestedText(s);
        if (text == null) {
          print("not closing 'else' statement, will not parse it and the rest of $s");
          return;
        }
        addTextPart(new ElseText(new Text.fromString(text)));
        s = s.substring(text.length+1);
        idxCondition = s.indexOf(_ifConditionOperator);
      }
    }
    _decodeTextAndGameVariables(s, addTextPart);
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

  static _decodeTextAndGameVariables(String s, Function addTextPart){
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
        addTextPart(DecodingHelper.decodeGameAPIVariable(currentTextPart.split('.')));
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