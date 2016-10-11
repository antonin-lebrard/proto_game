part of proto_game.text;


class IfText {
  StoredCondition condition;
  String text;
  IfText(this.condition, this.text);
}

class ElseText {
  String text;
  ElseText(this.text);
}

abstract class TextDecodingHelper {

  static final String _beginVariableOperator = r"${";
  static final String _endVariableOperator = "}";
  static final String _ifConditionOperator = "(if:";
  static final String _elseConditionOperator = "(else:";
  static final String _endConditionOperator = ")";
  static final List<String> _conditionsOperators = ["(if:", "(else:"];
  static final String _beginConditionText = '[';
  static final String _endConditionText = ']';

  static decompose(String s, Function addTextPart){
    List<String> parts = s.split(r"\n");
    for (String part in parts) {
      if (_conditionsOperators.any((String op) => part.startsWith(op))) {
        String text = part.substring(part.indexOf(_beginConditionText) + 1, part.indexOf(_endConditionText));
        String condition = part.trim().substring(0, part.indexOf(_endConditionOperator));
        if (condition.startsWith(_ifConditionOperator)){
          var conditionObj = new StoredCondition.fromString(null, condition.substring(_ifConditionOperator.length));
          addTextPart(new IfText(conditionObj, text));
        } else if (condition.startsWith(_elseConditionOperator)){
          addTextPart(new ElseText(text));
        }
      }
      else if (part.contains(_beginVariableOperator)) {
        List<dynamic> parts = new List();
        bool variableMode = false;
        String currentTextPart = "";
        StringScanner scanner = new StringScanner(part);
        while (!scanner.isDone){
          int char = scanner.readChar();
          if (!variableMode && char == $dollar && scanner.peekChar() == $open_brace){
            // found '${'
            parts.add(currentTextPart);
            currentTextPart = "";
            scanner.readChar(); // to skip '{'
            variableMode = true;
          } else if (variableMode && char == $close_brace) {
            // found '}'
            parts.add(DecodingHelper.decodeGameAPIVariable(currentTextPart.split('.')));
            currentTextPart = "";
            variableMode = false;
          } else {
            currentTextPart += new String.fromCharCode(char);
          }
        }
        addTextPart(parts);
      }
      else {
        addTextPart(part);
      }
    }
  }

}