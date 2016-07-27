part of proto_game.operation;


abstract class HasValue<T> {

  Type getType() => T;

  T getValue();

  bool operator ==(other) {
    return other is HasValue ? getValue() == other.getValue() : false;
  }

}

