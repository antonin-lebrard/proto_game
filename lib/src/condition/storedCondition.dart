part of proto_game.operation;


class StoredCondition {

  Type eventType;

  List<dynamic> wholeCondition = new List();

  StoredCondition.fromString(this.eventType, String condition) {
    DecodingHelper.decompose(condition, _decodeOperationPart, _decodeNestedStoredOperation);
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
      Logger.log(new DecodingError(s, "problem decoding operation part, operation part lenght == 0"));
      return;
    }
    if (DecodingHelper.isOperatorString(s[0])){
      Operation o = DecodingHelper.decodeOperation(s);
      if (o != null) {
        wholeCondition.add(o);
      }
      else Logger.log(new DecodingError(s, "problem decoding operator"));
    }
    else {
      HasValue v = DecodingHelper.decodeTempVariable(s, _decodeVariable);
      if (v != null){
        wholeCondition.add(v);
      }
      else Logger.log(new DecodingError(s, "problem decoding variable"));
    }
  }

  HasValue _decodeVariable(String s) {
    List<String> varPart = s.split('.');

    HasValue o = DecodingHelper.decodeExpectedEventVariable(varPart, eventType);
    if (o != null) return o;

    o = DecodingHelper.decodeGameAPIVariable(varPart);
    if (o != null) return o;

    return null;
  }

  _decodeNestedStoredOperation(String s){
    wholeCondition.add(new StoredOperation.fromString(s));
  }

}