part of proto_game.logger;




class ExposedAPIBrowsingException implements Exception {

  final List<String> path;

  final String stoppingKey;

  const ExposedAPIBrowsingException(this.path, this.stoppingKey);

  String toString(){
    return "Exception: Should never appear in console.\n"
        "Error Browsing exposedAPI Map at $stoppingKey from $path";
  }

}

class NoIfBeforeElseException implements Exception {

  const NoIfBeforeElseException();

  String toString(){
    return "Exception: Should never appear in console.\n"
        "No 'if' statement before else statement";
    }

}