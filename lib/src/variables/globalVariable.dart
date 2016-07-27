part of proto_game.variables;

abstract class GlobalVariable<T> extends HasValue<T> {

  String name;
  T value;

  GlobalVariable(this.name, this.value);

  T getValue() => value;

}

class StringGlobalVariable extends GlobalVariable<String>{
  StringGlobalVariable(String name, String value) : super(name, value);
}
class NumGlobalVariable extends GlobalVariable<num>{
  NumGlobalVariable(String name, num value) : super(name, value);
}
class BooleanGlobalVariable extends GlobalVariable<bool>{
  BooleanGlobalVariable(String name, bool value) : super(name, value);
}