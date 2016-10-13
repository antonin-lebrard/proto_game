part of proto_game.common;


abstract class HasValue<T> {

  T _value;

  HasValue(this._value);

  Type getType() => _value.runtimeType;

  T getValue() => _value;

  void applyValue(var other) {
    var applying = other is HasValue ? other.getValue() : other;
    _value = applying;
  }

  bool operator ==(other) {
    return other is HasValue ? getValue() == other.getValue() : false;
  }

}