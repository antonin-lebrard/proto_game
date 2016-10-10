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

  static final String _ifConditionOperator = "(if:";
  static final String _elseConditionOperator = "(else:";
  static final String _endConditionOperator = ")";
  static final List<String> _conditionsOperators = ["(if:", "(else:"];
  static final String _beginConditionText = '[';
  static final String _endConditionText = ']';

  static decompose(String s, Function addTextLine){
    List<String> lines = s.split(r"\n");
    for (String line in lines){
      if (!_conditionsOperators.any((String op) => line.startsWith(op)))
        addTextLine(line);
      else {
        String text = line.substring(line.indexOf(_beginConditionText) + 1, line.indexOf(_endConditionText));
        String condition = line.trim().substring(0, line.indexOf(_endConditionOperator));
        if (condition.startsWith(_ifConditionOperator)){
          var conditionObj = new StoredCondition.fromString(null, condition.substring(_ifConditionOperator.length));
          addTextLine(new IfText(conditionObj, text));
        } else if (condition.startsWith(_elseConditionOperator)){
          addTextLine(new ElseText(text));
        }
      }
    }
  }

}