part of proto_game.operation;


class TempVariable<T> extends HasValue<T>{

  TempVariable(T value) : super(value);

}

class ExpectedEventVariable extends HasValue {

  String name;
  Type expectedType;

  ExpectedEventVariable(this.name, this.expectedType) : super(null);

  void resolveVariable(Event event) { applyValue(event.properties[name]); }

  void resetVariable() { applyValue(null); }

}

class DecodingHelper {
  static String _allOperators = "+-/*%=><?:";
  static bool _stringMode = false;
  static bool _fromQuote = false;
  static bool get isStringMode => _stringMode;
  static stringMode(String fromLetter){
    if (!_stringMode) _enableStringMode(fromLetter);
    else _disableStringMode(fromLetter);
  }
  static _enableStringMode(String fromLetter){
    _stringMode = true;
    _fromQuote = (fromLetter == "'");
  }
  static _disableStringMode(String letter){
    if ((_fromQuote && letter == "'") || (!_fromQuote && letter == '"')){
      _stringMode = false;
      _fromQuote = false;
    }
  }
  static bool isOperator(String letter){
    return _allOperators.contains(letter);
  }

  static void decompose(String s, Function onOperationPart){
    s = s.trim();
    String currentDecodingPart = "";
    for (String letter in s.split('')){
      if (letter == "'" || letter == '"'){
        DecodingHelper.stringMode(letter);
      }
      if (!DecodingHelper.isStringMode) {
        if (letter == " ") {
          onOperationPart(currentDecodingPart);
          currentDecodingPart = "";
          continue;
        }
      }
      currentDecodingPart += letter;
    }
    onOperationPart(currentDecodingPart);
  }

  static Operation decodeOperation(String s){
    switch(s){
      case "==": return Operation.EQUALS_TO;
      case "=" : return Operation.ASSIGN;
      case "+" : return Operation.PLUS;
      case "-" : return Operation.MINUS;
      case "/" : return Operation.DIVIDE;
      case "*" : return Operation.MULTIPLY;
      case "%" : return Operation.MODULO;
      case "+=": return Operation.PLUS_ASSIGN;
      case "-=": return Operation.MINUS_ASSIGN;
      case "/=": return Operation.DIVIDE_ASSIGN;
      case "*=": return Operation.MULTIPLY_ASSIGN;
      case "%=": return Operation.MODULO_ASSIGN;
      case ">" : return Operation.SUPERIOR;
      case "<" : return Operation.INFERIOR;
      case ">=": return Operation.SUPERIOR_EQUALS;
      case "<=": return Operation.INFERIOR_EQUALS;
      case "?" : return Operation.CONDITIONAL;
      case ":" : return Operation.CONDITIONAL_SEPARATOR;
      default  :
        print("problem decoding event apply, wrong assumption made $s not an operation");
        return null;
    }
  }

  static Object decodeTempVariable(String s, Function ifNotTemp){
    if (new RegExp("[0-9]|\\.").hasMatch(s[0])){
      return new TempVariable<num>(num.parse(s));
    } else if (new RegExp("\"|'").hasMatch(s[0])){
      return new TempVariable<String>(s.substring(1, s.length-1));
    } else if (s == "true"){
      return new TempVariable<bool>(true);
    } else if (s == "false"){
      return new TempVariable<bool>(false);
    }
    return ifNotTemp(s);
  }

  static ExpectedEventVariable decodeExpectedVariable(List<String> varPart, Type eventType){
    if (varPart[0] == "param"){
      for (String key in EventMappings.eventMappings[eventType]['params'].keys){
        Type value = EventMappings.eventMappings[eventType]['params'][key];
        if (key == varPart[1]){
          return new ExpectedEventVariable(key, value);
        }
      }
    }
    return null;
  }
}