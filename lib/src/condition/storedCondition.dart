part of proto_game.operation;


class StoredCondition {

  Type eventType;

  List<Object> variables = new List();
  List<Operation> operations = new List();

  StoredCondition.fromString(EventConsumer parent, String condition) {
    this.eventType = parent.listenTo;
    DecodingHelper.decompose(condition, decodeOperationPart);
  }

  decodeOperationPart(String s) {
    if (s.length == 0) print("problem decoding operation part, operation part lenght == 0");
    if (DecodingHelper.isOperator(s[0])){
      Operation o = DecodingHelper.decodeOperation(s);
      if (o != null) operations.add(o);
      else print("problem decoding operator");
    }
    else {
      Object v = DecodingHelper.decodeTempVariable(s, decodeVariable);
      if (v != null) variables.add(v);
      else print("problem decoding variable");
    }
  }

  Object decodeVariable(String s) {
    List<String> varPart = s.split('.');

    Object o = DecodingHelper.decodeExpectedVariable(varPart, eventType);
    if (o != null) return o;

    if (varPart[0] == "global" || varPart[0] == "globals") {
      for (GlobalVariable g in Game.game.globals) {
        if (g.name == varPart[1]) {
          return g;
        }
      }
    }
    else if (varPart[0] == "player") {
      if (varPart[1] == "properties") {
        for (String key in Game.game.player.mapGlobalProperties.keys) {
          if (varPart[2] == key){
            return Game.game.player.mapGlobalProperties[key];
          }
        }
      }
    }
    else if (varPart[0] == "rooms") {
      for (Room room in Game.game.player.plateau.rooms) {
        if (room.id == varPart[1].hashCode) {
          return room;
        }
      }
    }
    return null;
  }

}