part of proto_game.logger;


abstract class Error {

  String getError();

}

class DecodingError extends Error {

  String textContainingError;
  String errorMessage;

  DecodingError(this.textContainingError, this.errorMessage);

  String getError(){
    String toReturn = this.errorMessage + ":\n" + this.textContainingError;
    return toReturn;
  }

}

class ExposedAPIBrowsingError extends Error {

  List<String> path;
  String stoppingKey;
  Map<String, dynamic> exposedAPI;

  ExposedAPIBrowsingError(this.exposedAPI, this.path, this.stoppingKey);

  String getError(){
    return "Error browsing exposedAPI, the key ${path.join(".")} leads to nowhere:\n"
        "ExposedAPI Object : $exposedAPI\n"
        "Path: $path\n"
        "Stopped at key: $stoppingKey";
  }

}

class MessageError extends Error {

  String message;

  MessageError(this.message);

  String getError(){
    return message;
  }

}