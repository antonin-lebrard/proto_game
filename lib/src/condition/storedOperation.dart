part of proto_game.operation;

class StoredOperation {

  List<HasValue> variables = new List();
  List<Operation> operations = new List();

  StoredOperation.fromString(String s){
    DecodingHelper.decompose(s, _decodeOperationPart);
  }

  void applyOperation() {
    OperationHelper.applyOperation(variables.toList(), operations.toList());
  }

  _decodeOperationPart(String s){
    if (s.length == 0) print("problem decoding operation part, operation part lenght == 0");
    if (DecodingHelper.isOperator(s[0])){
      Operation o = DecodingHelper.decodeOperation(s);
      if (o != null) operations.add(o);
      else print("problem decoding operator");
    }
    else {
      HasValue v = DecodingHelper.decodeTempVariable(s, _decodeVariable);
      if (v != null) variables.add(v);
      else print("problem decoding variable");
    }
  }

  HasValue _decodeVariable(String s) {
    List<String> varPart = s.split('.');
    if (varPart[0] == "global" || varPart[0] == "globals") {
      for (GlobalVariable g in Game.game.globals) {
        if (g.name == varPart[1]) {
          return g;
        }
      }
    }
    else if (varPart[0] == "player") {
      if (varPart[1] == "properties") {
        for (String key in Game.game.player.properties.keys) {
          if (varPart[2] == key){
            return Game.game.player.properties[key];
          }
        }
      }
    }
    return null;
  }

}