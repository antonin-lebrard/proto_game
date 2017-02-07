part of proto_game.operation;


class OperationHelper {

  static bool _isValidOperation(List<HasValue> variables, List<Operation> operations){
    if (!(variables.length == operations.length + 1)) return false;
    //if (!(operations.length > 0)) return false;
    //if (!(operations[0].isAssign)) return false;
    return true;
  }

  static bool _isValidCondition(List<HasValue> variables, List<Operation> operations){
    if (!(variables.length == operations.length + 1)) return false;
    if (!(operations.length > 0)) return false;
    if (!(operations[0].isCondition || operations[0] == Operation.CONDITIONAL)) return false;
    //if (operations.any((Operation elem) => elem.isAssign)) return false;
    return true;
  }

  static bool _isValidConditionalOperation(List<HasValue> variables, List<Operation> operations, int i){
    // TODO: Very demanding, can launch series of unnecessary nested computation with nested StoredOperation
    if (i == 0 && variables[0].getType() != true.runtimeType){
      Logger.log(new ShouldBeError(variables[0].getType(), "a boolean instance"));
      return false;
    }
    // TODO: Very demanding, same here
    if (i != 0 && !operations[i-1].isCondition && !(variables[i].getValue() is bool)){
        Logger.log(new ShouldBeListOrError([operations[i-1], variables[i].getValue()], "operation returning a boolean"));
        return false;
    }
    if (i == operations.length || operations[i+1] != Operation.CONDITIONAL_SEPARATOR){
      Logger.log(new ShouldBeError(operations[i+1], "a conditional operator ':', after a '?' operator"));
      return false;
    }
    return true;
  }

  /// return false if a wrong operation was found (stop all processing)
  static bool _processConditionalsOperations(List<HasValue> variables, List<Operation> operations){
    for (int i = 0; i < operations.length; i++){
      Operation curOp = operations[i];
      if (curOp == Operation.CONDITIONAL) {
        HasValue keptVariable;
        bool twoVariableCondition = false;
        if (!_isValidConditionalOperation(variables, operations, i)) return false;
        if (i != 0 && operations[i-1].isCondition){
          keptVariable = _isConditionTrue(variables[i-1], operations[i-1], variables[i]) ? variables[i+1] : variables[i+2];
          twoVariableCondition = true;
        } else {
          keptVariable = variables[i].getValue() ? variables[i+1] : variables[i+2];
        }
        if (keptVariable == null){
          Logger.log(new MessageError("something wrong happened : $variables : $operations"));
          return false;
        }
        int startRemoveRange = twoVariableCondition ? i-1 : i;
        variables.replaceRange(startRemoveRange, i+3, [keptVariable]);
        operations.removeRange(startRemoveRange, i+2);
      }
    }
    return true;
  }

  static bool _isConditionTrue(HasValue one, Operation operation, HasValue second){
    if (operation == Operation.INFERIOR)        return one.getValue() <  second.getValue();
    if (operation == Operation.INFERIOR_EQUALS) return one.getValue() <= second.getValue();
    if (operation == Operation.SUPERIOR)        return one.getValue() >  second.getValue();
    if (operation == Operation.SUPERIOR_EQUALS) return one.getValue() >= second.getValue();
    if (operation == Operation.EQUALS_TO)       return one.getValue() == second.getValue();
    return false;
  }

  static HasValue _doOperation(HasValue one, Operation operation, HasValue second){
    HasValue result;
    if (operation.isAssign){
      if (operation == Operation.ASSIGN)          result = one..applyValue(second.getValue());
      if (operation == Operation.PLUS_ASSIGN)     result = one..applyValue(one.getValue() + second.getValue());
      if (operation == Operation.MINUS_ASSIGN)    result = one..applyValue(one.getValue() - second.getValue());
      if (operation == Operation.DIVIDE_ASSIGN)   result = one..applyValue(one.getValue() / second.getValue());
      if (operation == Operation.MULTIPLY_ASSIGN) result = one..applyValue(one.getValue() * second.getValue());
      if (operation == Operation.MODULO_ASSIGN)   result = one..applyValue(one.getValue() % second.getValue());
    }
    if (operation.isCondition){
      result = new TempVariable(_isConditionTrue(one, operation, second));
    }
    if (operation.isOperand){
      if (operation == Operation.PLUS)     result = new TempVariable(one.getValue() + second.getValue());
      if (operation == Operation.MINUS)    result = new TempVariable(one.getValue() - second.getValue());
      if (operation == Operation.DIVIDE)   result = new TempVariable(one.getValue() / second.getValue());
      if (operation == Operation.MULTIPLY) result = new TempVariable(one.getValue() * second.getValue());
      if (operation == Operation.MODULO)   result = new TempVariable(one.getValue() % second.getValue());
    }
    return result;
  }

  static dynamic applyOperation(List<dynamic> toCopy){
    /// create a copy to de-reference toCopy, and not change it (toCopy.clone())
    List<dynamic> whole = new List.from(toCopy);
    optimizeOperationAtRuntime(whole);
    List<HasValue> variables = whole.where((var element) => element is HasValue).toList();
    List<Operation> operations = whole.where((var element) => element is Operation).toList();
    if (!_isValidOperation(variables, operations)){
      Logger.log(new RuntimeError(whole, "not a valid written computation"));
      return new TempVariable(null);
    }
    if (!_processConditionalsOperations(variables, operations)) return new TempVariable(null);
    int nbAssigns = operations.where((Operation elem) => elem.isAssign).length;
    HasValue result = variables[0];
    while (operations.length > 0){
      result = _doOperation(variables[variables.length - 2], operations.last, variables.last);
      if (result == null){
        Logger.log(new RuntimeError(whole, "something wrong happened in the calculation, the operations seems to be not correct or supported"));
        if (nbAssigns != 0 && nbAssigns != operations.where((Operation elem) => elem.isAssign).length){
          Logger.log(new MessageError("Sould propably exit game now, as assignements were made, propably corrupting variables"));
        } else {
          Logger.log(new MessageError("no assignements made, could continue game, but you should probably check written computation"));
        }
        return new TempVariable(null);
      }
      variables..removeLast()..removeLast()..add(result);
      operations.removeLast();
    }
    return result.getValue();
  }

  static bool applyCondition(List<dynamic> toCopy){
    /// create a copy to de-reference toCopy, and not change it (toCopy.clone())
    List<dynamic> whole = new List.from(toCopy);
    optimizeOperationAtRuntime(whole);
    List<HasValue> variables = whole.where((var element) => element is HasValue).toList();
    List<Operation> operations = whole.where((var element) => element is Operation).toList();
    if (!_isValidCondition(variables, operations)){
      Logger.log(new RuntimeError(whole, "not a valid written condition"));
      return false;
    }
    if (!_processConditionalsOperations(variables, operations)) return false;
    HasValue result;
    while (operations.length > 0){
      result = _doOperation(variables[variables.length - 2], operations.last, variables.last);
      if (result == null){
        Logger.log(new RuntimeError(whole, "something wrong happened in the calculation, the operations seems to be not correct or supported"));
        return false;
      }
      variables..removeLast()..removeLast()..add(result);
      operations.removeLast();
    }
    return result.getValue();
  }

  /**
   * For now, remove - or + Operator before a [TempVariable] if there is an operator before it
   *
   * Example : var += - 1 :
   * will be represented as [var, +=, -, 1] before.
   *                becomes [var, +=, -1] after
   */
  static void optimizeOperationAtParsing(List<dynamic> whole){
    for (int i = 0; i < whole.length; i++){
      if (whole[i] is StoredOperation){
        if (whole[i].wholeOperation.length == 0){
          whole.removeAt(i);
          i--;
        } else if (whole[i].wholeOperation.length == 1){
          whole[i] = whole[i].wholeOperation[0];
        }
      }
    }
    if (whole.length < 3) return;
    for (int i = 1; i < whole.length - 1; i++){
      if (whole[i] is Operation
          && (whole[i] == Operation.PLUS || whole[i] == Operation.MINUS)
          && whole[i-1] is Operation
          && whole[i+1] is TempVariable<num>)
      {
        if (whole[i] == Operation.MINUS)
          whole[i+1].applyValue(- whole[i+1].getValue());
        whole.removeAt(i);
        i--;
      }
    }
  }

  /**
   * For now, remove - or + Operator before a [HasValue] if there is an operator before it
   *
   * Example : var += - 1 :
   * will be represented as [var, +=, -, var2] before.
   *                becomes [var, +=, -var2] after
   */
  static void optimizeOperationAtRuntime(List<dynamic> whole) {
    if (whole.length < 3) return;
    for (int i = 1; i < whole.length - 1; i++) {
      if (whole[i] is Operation
          && (whole[i] == Operation.PLUS || whole[i] == Operation.MINUS)
          && whole[i - 1] is Operation
          && whole[i + 1] is HasValue<num>) {
        if (whole[i] == Operation.MINUS)
          whole[i + 1] = new TempVariable<num>(-whole[i + 1].getValue());
        whole.removeAt(i);
        i--;
      }
    }
  }

  static bool isTemporaryOnlyOperation(List<dynamic> whole){
    return whole
        .where((dynamic el) => el is HasValue)
        .every((HasValue el) => el is TempVariable);
  }

}