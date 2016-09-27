part of proto_game.operation;

class StoredOperation {

  List<HasValue> variables = new List();
  List<Operation> operations = new List();

  bool isFunction = false;

  Function toExecute;

  StoredOperation.fromString(String s){
    DecodingHelper.decompose(s, _decodeOperationPart);
  }

  void applyOperation() {
    if (isFunction) toExecute();
    else OperationHelper.applyOperation(variables.toList(), operations.toList());
  }

  _decodeOperationPart(String s){
    if (s.length == 0) print("problem decoding operation part, operation part lenght == 0");
    if (DecodingHelper.isOperator(s[0])){
      Operation o = DecodingHelper.decodeOperation(s);
      if (o != null) operations.add(o);
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
      if (v != null) variables.add(v);
      else print("problem decoding variable $s");
    }
  }

  HasValue _decodeVariable(String s) {
    List<String> varPart = s.split('.');
    try {
      if (varPart[0] == "global" || varPart[0] == "globals") {
        for (GlobalVariable g in Game.game.globals) {
          if (g.name == varPart[1]) {
            return g;
          }
        }
      }
      else if (varPart[0] == "player") {
        if (varPart[1] == "properties") {
          return Game.game.player.properties[varPart[2]];
        }
      }
      else if (varPart[0] == "npcs") {
        Npc npc = Game.game.getNpcByName(varPart[1]);
        if (npc != null) {
          if (varPart[2] == "properties"){
            return npc.properties[varPart[3]];
          }
        }
      }
    } on IndexError {
      return null;
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
    return null;
  }

}