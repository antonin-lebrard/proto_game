part of proto_game.game;

class Game {

  static Game game;

  Game._internal(this.lowLevelIo){
    eventsManagerInstance = new EventsManager();
  }

  factory Game(LowLevelIo io){
    if (game == null)
      game = new Game._internal(io);
    return game;
  }

  LowLevelIo lowLevelIo;

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