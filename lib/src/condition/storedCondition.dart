part of proto_game.operation;


class StoredCondition {

  Type eventType;

  List<dynamic> wholeCondition = new List();

  StoredCondition.fromString(this.eventType, String condition) {
    DecodingHelper.decompose(condition, _decodeOperationPart);
    OperationHelper.optimizeOperationAtParsing(wholeCondition);
  }

  bool isConditionTrue(Event event){
    wholeCondition.where((var elem) => elem is ExpectedEventVariable).forEach((ExpectedEventVariable e) => e.resolveVariable(event));
    bool result = OperationHelper.applyCondition(wholeCondition);
    // need to reset value of these variables, to not have reminiscence of old values at the next event
    wholeCondition.where((var elem) => elem is ExpectedEventVariable).forEach((ExpectedEventVariable e) => e.resetVariable());
    return result;
  }

  _decodeOperationPart(String s) {
    if (s.length == 0) {
      print("problem decoding operation part, operation part lenght == 0");
      return;
    }
    if (DecodingHelper.isOperatorString(s[0])){
      Operation o = DecodingHelper.decodeOperation(s);
      if (o != null) {
        wholeCondition.add(o);
      }
      else print("problem decoding operator $s");
    }
    else {
      HasValue v = DecodingHelper.decodeTempVariable(s, _decodeVariable);
      if (v != null){
        wholeCondition.add(v);
      }
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
  }

}