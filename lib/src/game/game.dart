part of proto_game.game;

class Game {

  static Game game;

  Game._internal(){
    eventsManagerInstance = new EventsManager();
  }

  factory Game(){
    if (game == null)
    game = new Game._internal();
    return game;
  }

  EventsManager eventsManagerInstance;

  Player player;

  List<GlobalVariable> globals;

  set consumers(List<EventConsumer> consumers) {
    consumers.forEach((EventConsumer ec){
      eventsManagerInstance.addEventListener(ec.listenTo, ec);
    });
  }

  Iterable<EventConsumer> get consumers => eventsManagerInstance.consumers;

}