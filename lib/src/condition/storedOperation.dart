part of proto_game.operation;

class StoredOperation implements HasValue {

  List<dynamic> wholeOperation = new List();

  bool isFunction = false;

  Function toExecute;

  StoredOperation.fromString(String s){
    DecodingHelper.decompose(s, _decodeOperationPart, _decodeNestedStoredOperation);
    OperationHelper.optimizeOperationAtParsing(wholeOperation);
  }

  /// Create copy of other
  ///
  /// Can use [List.map] function as complementary way to handle [other] operation parts
  StoredOperation.from(StoredOperation other, {dynamic map(dynamic element)}) {
    if (!other.isFunction) {
      if (map == null) map = (element) => element;
      wholeOperation.addAll(other.wholeOperation.map(map));
    } else {
      Logger.log(new MessageError("Warning, pointless to use copy constructor for function Operation"));
      toExecute = other.toExecute;
      isFunction = true;
    }
  }

  dynamic applyOperation({HasProperties context: null}) {
    if (isFunction) return toExecute();
    else {
      if (context != null) {
        wholeOperation.where((element) => element is ExpectedContextVariable).forEach((ExpectedContextVariable v) => v.resolveVariable(context));
      }
      var result = OperationHelper.applyOperation(wholeOperation);
      if (context != null) {
        wholeOperation.where((element) => element is ExpectedContextVariable).forEach((ExpectedContextVariable v) => v.resetVariable());
      }
      return result;
    }
  }

  _decodeOperationPart(String s){
    if (s.length == 0) {
      Logger.log(new DecodingError(s, "problem decoding operation part, operation part lenght == 0"));
      return;
    }
    if (DecodingHelper.isOperatorString(s[0])){
      Operation o = DecodingHelper.decodeOperation(s);
      if (o != null) {
        wholeOperation.add(o);
      }
      else Logger.log(new DecodingError(s, "problem decoding operator"));
    }
    else if (DecodingHelper.isFunction(s)){
      Function f = _decodeFunction(s);
      if (f != null) {
        isFunction = true;
        toExecute = f;
      }
      else Logger.log(new DecodingError(s, "problem decoding function"));
    }
    else {
      HasValue v = DecodingHelper.decodeTempVariable(s, _decodeVariable);
      if (v != null) {
        wholeOperation.add(v);
      }
      else Logger.log(new DecodingError(s, "problem decoding variable"));
    }
  }

  HasValue _decodeVariable(String s) {
    List<String> varPart = s.split('.');

    if (varPart[0] == "context"){
      HasValue o = DecodingHelper.decodeExpectedContextVariable(varPart);
      if (o != null) return o;
    }
    else {
      HasValue o = DecodingHelper.decodeGameAPIVariable(varPart);
      if (o != null) return o;
    }
    return null;
  }

  Function _decodeFunction(String s){
    List<String> varPart = s.split('.');
    if (varPart[0] == "player"){
      if (varPart[1].startsWith("addObject(")){
        return DecodingHelper.generateObjectAction(varPart[1], "take");
      }
      else if (varPart[1].startsWith("dropObject(")){
        return DecodingHelper.generateObjectAction(varPart[1], "drop");
      }
      else if (varPart[1].startsWith("wearObject(")){
        return DecodingHelper.generateObjectAction(varPart[1], "wear");
      }
      else if (varPart[1].startsWith("removeObject(")){
        return DecodingHelper.generateObjectAction(varPart[1], "remove");
      }
      else if (varPart[1].startsWith("useObject(")){
        return DecodingHelper.generateObjectAction(varPart[1], "use");
      }
    }
    else if (varPart[0].startsWith("provokeChoice(")){
      return DecodingHelper.generateProvokeChoiceAction(varPart[0]);
    }
    return null;
  }

  _decodeNestedStoredOperation(String s){
    wholeOperation.add(new StoredOperation.fromString(s));
  }

  void applyValue(other) {
    throw "Cannot apply value to a StoredOperation";
  }

  Type getType() => dynamic;

  getValue() => this.applyOperation();
}