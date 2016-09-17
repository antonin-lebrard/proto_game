part of proto_game.operation;


abstract class HasValue<T> {

  T _value;

  HasValue(this._value);

  Type getType() => _value.runtimeType;

  T getValue() => _value;

  void applyValue(T other) { _value = other; }

  bool operator ==(other) {
    return other is HasValue ? getValue() == other.getValue() : false;
  }

}

