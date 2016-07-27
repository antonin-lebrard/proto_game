part of proto_game.game;

class Game {

  static Game game;

  Game._internal(){}

  factory Game(){
    if (game == null)
      game = new Game._internal();
    return game;
  }

  Player player;

  List<GlobalVariable> globals;

  List<EventConsumer> consumers;

}