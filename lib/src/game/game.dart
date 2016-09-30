part of proto_game.game;

class Game {

  static Game game;

  Game._internal(this.lowLevelIo){
    gameLinkIo = new GameLinkIo(this.lowLevelIo);
    evtManagerInstance = new EventsManager();
  }

  factory Game(LowLevelIo io){
    if (game == null)
      game = new Game._internal(io);
    return game;
  }

  LowLevelIo lowLevelIo;
  GameLinkIo gameLinkIo;

  EventsManager evtManagerInstance;

  Player player;

  List<GlobalVariable> globals;

  SplayTreeMap<num, BaseGameObject> objectStorage;

  SplayTreeMap<num, Npc> npcStorage;

  HashMap<String, dynamic> api = new HashMap<String, dynamic>();

  BaseGameObject getObjectById(String id) => objectStorage[id.hashCode];

  Npc getNpcById(String id) => npcStorage[id.hashCode];

  set consumers(List<EventConsumer> consumers) {
    consumers.forEach((EventConsumer ec){
      evtManagerInstance.addEventListener(ec.listenTo, ec);
    });
  }

  Iterable<EventConsumer> get consumers => evtManagerInstance.consumers;

  void initAPI(){
    HashMap<String, dynamic> objectsApi = new HashMap<String, dynamic>();
    objectStorage.values.forEach((BaseGameObject b) => objectsApi.addAll(b.exposeAPI()));
    HashMap<String, dynamic> npcsApi = new HashMap<String, dynamic>();
    npcStorage.values.forEach((Npc n) => npcsApi.addAll(n.exposeAPI()));
    HashMap<String, dynamic> globalsApi = new HashMap<String, dynamic>();
    globals.forEach((GlobalVariable g) => globalsApi[g.name] = g);
    HashMap<String, dynamic> roomsApi = new HashMap<String, dynamic>();
    player.plateau.rooms.forEach((Room r) => roomsApi.addAll(r.exposeAPI()));
    api.addAll({
      "player": player.exposeAPI(),
      "objects": objectsApi,
      "npcs": npcsApi,
      "globals": globalsApi,
      "rooms": roomsApi
    });
    /// Just for display in debug mode
    Map<String, dynamic> toDisplayInDebug = new Map()..addAll(api);
    for (String key in toDisplayInDebug.keys){
      toDisplayInDebug[key] = new Map()..addAll(toDisplayInDebug[key]);
    }
  }

}