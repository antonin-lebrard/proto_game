part of proto_game.operation;


class OperationHelper {

  static bool _isValidOperations(List<HasValue> variables, List<Operation> operations){
    if (!(variables.length == operations.length + 1)) return false;
    if (!(operations.length > 0)) return false;
    if (!(operations[0].isAssign)) return false;
    return true;
  }

  static bool _isValidConditionalOperation(List<HasValue> variables, List<Operation> operations, int i){
    if (i == 0 || (!operations[i-1].isCondition && !(variables[i].getValue() is bool))){
      print("Wrong operation : not a condition before '?' operator");
      return false;
    }
    if (i == operations.length || operations[i+1] != Operation.CONDITIONAL_SEPARATOR){
      print("Wrong operation : no conditional separator ':' after '?' operator");
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
        if (operations[i-1].isCondition){
          keptVariable = _isConditionTrue(variables[i-1], operations[i-1], variables[i]) ? variables[i+1] : variables[i+2];
          twoVariableCondition = true;
        } else {
          keptVariable = variables[i].getValue() ? variables[i+1] : variables[i+2];
        }
        if (keptVariable == null){
          print("Wrong operation : something wrong happened : $variables : $operations");
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

  static void applyOperation(List<HasValue> variables, List<Operation> operations){
    if (!_isValidOperations(variables, operations)){
      print("Operation not valid");
      return;
    }
    if (!_processConditionalsOperations(variables, operations)) return;
    int nbAssigns = operations.takeWhile((Operation elem) => elem.isAssign).length;
    while (operations.length > 0){
      HasValue result = _doOperation(variables[variables.length - 2], operations.last, variables.last);
      if (result == null){
        print("Wrong operation : something wrong happened in the calculation");
        if (nbAssigns != 0 && nbAssigns != operations.takeWhile((Operation elem) => elem.isAssign).length){
          print("Sould propably exit game now, as assignements were made, propably corrupting variables");
        } else {
          print("no assignements made, could continue game, but you should probably check operations");
        }
        return;
      }
      variables..removeLast()..removeLast()..add(result);
      operations.removeLast();
    }
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

}