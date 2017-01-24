library proto_game.logger;


part 'error.dart';
part 'exception.dart';


enum LoggingLevel {
  ALL,
  NOTHING
}

class Logger {

  static LoggingLevel CURRENT_LOGGING_LEVEL = LoggingLevel.ALL;

  static log(Error error) {
    if (CURRENT_LOGGING_LEVEL == LoggingLevel.ALL){
      print(error);
    }
  }

}