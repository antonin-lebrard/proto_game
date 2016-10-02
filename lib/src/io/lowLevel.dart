part of proto_game.io;


abstract class LowLevelIo {

  /**
   * Prints [string] as it is
   */
  void writeString(String string);

  /**
   * Prints [line], with line-end inserted AFTER
   */
  void writeLine(String line);

  /**
   * Prints [line], with line-end inserted BEFORE and AFTER
   */
  void writeNewLine(String line);

  /**
   * Remove [nb] chars from output
   */
  void removeChars(int nb);

  /**
   * Wait for input from user, should be blocking
   */
  Future<String> readLine();

  /**
   * Present a list of choices, and wait for the user to choose one
   */
  Future<String> presentChoices(List<String> choices);

  /**
   * Clear Output
   */
  void clear();

}