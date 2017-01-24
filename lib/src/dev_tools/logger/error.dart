part of proto_game.logger;


abstract class Error {

  const Error();

  String toString();

}

class DecodingError extends Error {

  final String textContainingError;
  final String errorMessage;

  const DecodingError(this.textContainingError, this.errorMessage);

  String toString(){
    String toReturn = this.errorMessage + ":\n" + this.textContainingError;
    return toReturn;
  }

}

class ExposedAPIBrowsingError extends Error {

  final List<String> path;
  final String stoppingKey;
  final Map<String, dynamic> exposedAPI;

  const ExposedAPIBrowsingError(this.exposedAPI, this.path, this.stoppingKey);

  String toString(){
    return "Error browsing exposedAPI, the key ${path.join(".")} leads to nowhere:\n"
        "ExposedAPI Object : $exposedAPI\n"
        "Path: $path\n"
        "Stopped at key: $stoppingKey";
  }

}

class RuntimeError extends Error {

  final Object object;
  final String errorMessage;

  const RuntimeError(this.object, this.errorMessage);

  String toString(){
    return this.errorMessage + ":\n" + this.object.toString() +
        "\n(Attempt at calling toString() on object causing error, can print 'Instance of [runtimeType of object]' if toString() is not implemented";
  }

}

class ShouldBeError extends Error {

  final Object object;
  final String shouldBeMessage;

  const ShouldBeError(this.object, this.shouldBeMessage);

  String toString(){
    return "$object should be $shouldBeMessage";
  }

}

class ShouldBeListOrError extends Error {

  final List<Object> list;
  final String shouldBeMessage;

  const ShouldBeListOrError(this.list, this.shouldBeMessage);

  String toString(){
    return this.list.join(", or ") + "should be $shouldBeMessage";
  }

}

class MessageError extends Error {

  final String message;

  const MessageError(this.message);

  String toString(){
    return message;
  }

}