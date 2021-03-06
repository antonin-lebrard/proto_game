part of proto_game.operation;


class TempVariable<T> extends HasValue<T>{

  TempVariable(T value) : super(value);

}

class ExpectedEventVariable extends HasValue {

  List<String> nameParts;
  Type expectedType;

  ExpectedEventVariable(this.nameParts, this.expectedType) : super(null);

  void resolveVariable(Event event) {
    // applying the object
    if (nameParts.length == 1)
      applyValue(event.properties[nameParts[0]]);
    // trying to reach a property from the object
    else {
      var evtVar = event.properties[nameParts[0]];
      if (evtVar is ExposedAPI) {
        Map<String, dynamic> exposedApi = evtVar.exposeAPI();
        if (evtVar is HasId)
          exposedApi = exposedApi[evtVar.getId()];
        try {
          evtVar = ExposedAPI.getVarFromPath(exposedApi, nameParts.sublist(1));
          applyValue(evtVar);
        } on ExposedAPIBrowsingException catch (e) {
          Logger.log(new ExposedAPIBrowsingError(exposedApi, nameParts.sublist(1), e.stoppingKey));
          applyValue(null);
        }
      }
    }
  }

  void resetVariable() { applyValue(null); }

}

class ExpectedContextVariable extends HasValue {

  String name;

  ExpectedContextVariable(this.name) : super(null);

  void resolveVariable(HasProperties context) { applyValue(context.getProperty(name)); }

  void resetVariable() { applyValue(null); }

}

/*class DebugStringDisplay {
  String string;
  int idx;
  DebugStringDisplay(this.string, this.idx);
  String toString(){
    String toReturn = string + "\n";
    for (int i = 0; i < idx; i++)
        toReturn += " ";
    return toReturn + "^";
  }
}*/

abstract class DecodingHelper {
  static String _allOperatorsString = "+-/*%=><?:";
  static List<int> _allOperators = [$plus, $minus, $division, $asterisk, $percent, $equal, $greater_than, $less_than, $question, $colon];
  static String _functionDelimiters = "()";
  static bool _stringMode = false;
  static bool _fromQuote = false;
  static stringMode(int fromChar){
    if (!_stringMode) _enableStringMode(fromChar);
    else _disableStringMode(fromChar);
  }
  static _enableStringMode(int char){
    _stringMode = true;
    _fromQuote = (char == $quote);
  }
  static _disableStringMode(int char){
    if ((_fromQuote && char == $quote) || (!_fromQuote && char == $apostrophe)){
      _stringMode = false;
      _fromQuote = false;
    }
  }
  static bool isOperator(int char){
    return _allOperators.contains(char);
  }
  static bool isOperatorString(String letter){
    return _allOperatorsString.contains(letter);
  }

  static bool isFunction(String s){
    return _functionDelimiters.split('').every((String letter) => s.contains(letter));
  }

  static String reverseString(String s){
    String r = "";
    for (int i = s.length-1; i >= 0; i--)
        r += s[i];
    return r;
  }

  /// linearly check [String] and check diverse conditions to find pseudoCode parts
  ///
  /// Should be called only when parsing the game
  static void decompose(String s,
      Function onOperationPart(String),
      Function onNestedStoredOperation(String))
  {
    _stringMode = false;
    _fromQuote = false;
    bool nestedOperationMode = false;
    String nestedOperationString = "";
    int nestedParenthesisCount = 0;
    s = s.trim();
    String currentDecodingPart = "";
    StringScanner scanner = new StringScanner(s);
    while (!scanner.isDone) {
      int char = scanner.readChar();
      //String debug = new String.fromCharCode(char);
      if (char == $quote || char == $apostrophe) {
        DecodingHelper.stringMode(char);
      }
      if (!DecodingHelper._stringMode) {
        if (!nestedOperationMode) {
          if (char == $space) {
            if (currentDecodingPart.length > 0)
              onOperationPart(currentDecodingPart);
            currentDecodingPart = "";
            continue;
          }
          if (DecodingHelper.isOperator(char)) {
            if (currentDecodingPart.length > 0)
              onOperationPart(currentDecodingPart);
            currentDecodingPart = "";
            List<int> charCodes = [char];
            if (scanner.peekChar() == $equal) {
              charCodes.add(scanner.readChar());
            }
            onOperationPart(new String.fromCharCodes(charCodes));
            continue;
          }
          if (char == $lparen){
            int precChar = scanner.peekChar(-2);
            if (precChar == $space || DecodingHelper.isOperator(precChar)) {
              nestedOperationMode = true;
              continue;
            }
          }
        }
        if (nestedOperationMode){
          if (char == $rparen && nestedParenthesisCount == 0) {
            if (nestedOperationString.length > 0)
              onNestedStoredOperation(nestedOperationString);
            nestedOperationString = "";
            nestedOperationMode = false;
            continue;
          }
          if (char == $lparen)
            nestedParenthesisCount++;
          if (char == $rparen)
            nestedParenthesisCount--;
          nestedOperationString += new String.fromCharCode(char);
          continue;
        }
      }
      currentDecodingPart += new String.fromCharCode(char);
    }
    onOperationPart(currentDecodingPart);
    DecodingHelper._stringMode = false;
  }

  static String fillTernaryConditionsWithParenthesis(String s){
    if (!s.contains('?'))
      return s;
    String modifiedS = "(" + s + ")";
    int forwardIdx = 1, backwardIdx = modifiedS.length - 2;
    /*DebugStringDisplay forwardLetter = new DebugStringDisplay(modifiedS, forwardIdx);
    DebugStringDisplay backwardLetter = new DebugStringDisplay(modifiedS, backwardIdx);*/
    while (forwardIdx != backwardIdx){
      if (modifiedS[forwardIdx] == '?'){
        while(modifiedS[backwardIdx] != ':') {
          backwardIdx--;
          if (backwardIdx <= forwardIdx) {
            Logger.log(new DecodingError(s, "Wrong ternary operation use (condition ? operation : operation)"));
            return s;
          }
        }
      }
      if (modifiedS[backwardIdx] == ':'){
        while(modifiedS[forwardIdx] != '?') {
          forwardIdx++;
          if (forwardIdx >= backwardIdx) {
            Logger.log(new DecodingError(s, "Wrong ternary operation use (condition ? operation : operation)"));
            return s;
          }
        }
      }
      /*forwardLetter = new DebugStringDisplay(modifiedS, forwardIdx);
      backwardLetter = new DebugStringDisplay(modifiedS, backwardIdx);
      print("before -----------");
      print(forwardLetter);
      print(backwardLetter);*/
      if (modifiedS[forwardIdx] == '?' && modifiedS[backwardIdx] == ':') {
        bool containsNestedTernaries = modifiedS.substring(forwardIdx+1, backwardIdx).contains("?");
        int oldLength = modifiedS.length;
        modifiedS = modifiedS.substring(0, forwardIdx)
            + ")?("
            + (containsNestedTernaries ? "(" : "")
            + modifiedS.substring(forwardIdx + 1, backwardIdx)
            + (containsNestedTernaries ? ")" : "")
            + "):("
            + modifiedS.substring(backwardIdx + 1);
        if (!containsNestedTernaries)
          return modifiedS;
        backwardIdx += modifiedS.length - oldLength - 2;
        forwardIdx++;
        /*forwardLetter = new DebugStringDisplay(modifiedS, forwardIdx);
        backwardLetter = new DebugStringDisplay(modifiedS, backwardIdx);
        print("after ---------------");
        print(forwardLetter);
        print(backwardLetter);*/
      }
      forwardIdx++;
    }
    return modifiedS;
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
        Logger.log(new DecodingError(s, "problem decoding event apply, wrong assumption made $s not an operation"));
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

  static ExpectedEventVariable decodeExpectedEventVariable(List<String> varPart, Type eventType){
    if (eventType != null && varPart[0] == "param"){
      for (String key in EventMappings.eventMappings[eventType]['params'].keys){
        Type value = EventMappings.eventMappings[eventType]['params'][key];
        if (key == varPart[1]){
          return new ExpectedEventVariable(varPart.sublist(1), value);
        }
      }
    }
    return null;
  }

  static ExpectedContextVariable decodeExpectedContextVariable(List<String> varPart){
    if (varPart.length != 2) return null;
    return new ExpectedContextVariable(varPart[1]);
  }

  static HasValue decodeGameAPIVariable(List<String> varPart){
    var currentNodeAPI = Game.game.api;
    for (String part in varPart) {
      currentNodeAPI = currentNodeAPI[part];
      if (currentNodeAPI == null) {
        Logger.log(new DecodingError(varPart.toString(), "api variable not found"));
        break;
      }
    }
    if (currentNodeAPI is Map)
      currentNodeAPI = currentNodeAPI["object"];
    if (!(currentNodeAPI is HasValue))
      currentNodeAPI = new TempVariable(currentNodeAPI);
    return currentNodeAPI;
  }

  static String extractFunctionParam(String s){
    if (!isFunction(s)){
      Logger.log(new DecodingError(s, "problem extracting param"));
      return null;
    }
    return s.substring(s.indexOf("(")+1, s.indexOf(")"));
  }

  static Function generateObjectAction(String functionCall, String action){
    String objectId = DecodingHelper.extractFunctionParam(functionCall);
    if (objectId == null) return null;
    BaseGameObject object = Game.game.getObjectById(objectId);
    if (object == null) {
      Logger.log(new DecodingError(objectId, "objectId not found"));
      return null;
    }
    return () => object.executeAction(action);
  }

  static Function generateProvokeChoiceAction(String functionCall){
    String choiceId = DecodingHelper.extractFunctionParam(functionCall);
    if (choiceId == null) return null;
    InteractionChoice choice = Game.game.getInteractionChoiceById(choiceId);
    if (choiceId == null) {
      Logger.log(new DecodingError(choiceId, "choiceId not found"));
      return null;
    }
    return () => choice.execute();
  }

}