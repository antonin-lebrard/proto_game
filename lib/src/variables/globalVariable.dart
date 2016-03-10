part of proto_game.variables;

abstract class GlobalVariable<T> {

  String name;
  T value;

}

class StringGlobalVariable extends GlobalVariable<String>{}
class NumGlobalVariable extends GlobalVariable<num>{}
class BooleanGlobalVariable extends GlobalVariable<bool>{}