part of proto_game.operation;


class StoredCondition {

  Type eventType;

  List<HasValue> variables = new List();
  List<Operation> operations = new List();

  StoredCondition.fromString(this.eventType, String condition) {
    DecodingHelper.decompose(condition, _decodeOperationPart);
  }

  bool isConditionTrue(Event event){
    variables.where((HasValue elem) => elem is ExpectedEventVariable).forEach((ExpectedEventVariable e) => e.resolveVariable(event));
    bool result = OperationHelper.applyCondition(variables.toList(), operations.toList());
    // need to reset value of these variables, to not have reminiscence of old values at the next event
    variables.where((HasValue elem) => elem is ExpectedEventVariable).forEach((ExpectedEventVariable e) => e.resetVariable());
    return result;
  }

  _decodeOperationPart(String s) {
    if (s.length == 0) {
      print("problem decoding operation part, operation part lenght == 0");
      return;
    }
    if (DecodingHelper.isOperatorString(s[0])){
      Operation o = DecodingHelper.decodeOperation(s);
      if (o != null) operations.add(o);
      else print("problem decoding operator $s");
    }
    else {
      HasValue v = DecodingHelper.decodeTempVariable(s, _decodeVariable);
      if (v != null) variables.add(v);
      else print("problem decoding variable $s");
    }
  }

  HasValue _decodeVariable(String s) {
    List<String> varPart = s.split('.');

    HasValue o = DecodingHelper.decodeExpectedVariable(varPart, eventType);
    if (o != null) return o;

    o = DecodingHelper.decodeGameAPIVariable(varPart);
    if (o != null) return o;

    return null;
    /*try {
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
      else if (varPart[0] == "rooms") {
        for (Room room in Game.game.player.plateau.rooms) {
          if (room.name_id == varPart[1]) {
            return new TempVariable(room);
          }
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
    return null;*/
  }

}