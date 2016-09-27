part of proto_game.game;

class Game {

  static Game game;

  Game._internal(this.lowLevelIo){
    evtManagerInstance = new EventsManager();
  }

  factory Game(LowLevelIo io){
    if (game == null)
      game = new Game._internal(io);
    return game;
  }

  LowLevelIo lowLevelIo;

  EventsManager evtManagerInstance;

  Player player;

  List<GlobalVariable> globals;

  SplayTreeMap<num, BaseGameObject> objectStorage;

  SplayTreeMap<num, Npc> npcStorage;

  BaseGameObject getObjectByName(String name) => objectStorage[name.hashCode];

  Npc getNpcByName(String name) => npcStorage[name.hashCode];

  set consumers(List<EventConsumer> consumers) {
    consumers.forEach((EventConsumer ec){
      evtManagerInstance.addEventListener(ec.listenTo, ec);
    });
  }

  Iterable<EventConsumer> get consumers => evtManagerInstance.consumers;

}