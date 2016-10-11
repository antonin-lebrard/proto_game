part of proto_game.operation;

class StoredOperation {

  List<dynamic> wholeOperation = new List();

  bool isFunction = false;

  Function toExecute;

  StoredOperation.fromString(String s){
    DecodingHelper.decompose(s, _decodeOperationPart);
    OperationHelper.optimizeOperationAtParsing(wholeOperation);
  }

  dynamic applyOperation() {
    if (isFunction) return toExecute();
    else return OperationHelper.applyOperation(wholeOperation);
  }

  _decodeOperationPart(String s){
    if (s.length == 0) {
      print("problem decoding operation part, operation part lenght == 0");
      return;
    }
    if (DecodingHelper.isOperatorString(s[0])){
      Operation o = DecodingHelper.decodeOperation(s);
      if (o != null) {
        wholeOperation.add(o);
      }
      else print("problem decoding operator $s");
    }
    else if (DecodingHelper.isFunction(s)){
      Function f = _decodeFunction(s);
      if (f != null) {
        isFunction = true;
        toExecute = f;
      }
      else print("problem decoding function $s");
    }
    else {
      HasValue v = DecodingHelper.decodeTempVariable(s, _decodeVariable);
      if (v != null) {
        wholeOperation.add(v);
      }
      else print("problem decoding variable $s");
    }
  }

  HasValue _decodeVariable(String s) {
    List<String> varPart = s.split('.');

    HasValue o = DecodingHelper.decodeGameAPIVariable(varPart);
    if (o != null) return o;

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

}