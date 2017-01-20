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

class MessageError extends Error {

  String message;

  MessageError(this.message);

  String getError(){
    return message;
  }

}