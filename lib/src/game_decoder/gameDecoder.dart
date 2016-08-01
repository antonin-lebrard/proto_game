part of proto_game.gameDecoder;

/**
 * Decode/Encode a game from a format.
 * Implementations:
 *  - [GameDecoderJSON] for JSON.
 *  - maybe others later.
 */
abstract class GameDecoderBase {
  String writeToFormat();
  Game readFromFormat(String content);
}

class GameDecoderJSON extends GameDecoderBase {

  @override
  String writeToFormat(){return "null";}

  @override
  Game readFromFormat(String content){
    Map<String, dynamic> gameJson = JSON.decode(content)["game"];
    Game game = new Game();
    for (String key in gameJson.keys){
      switch(key){
        case Globals.GLOBALS_KEY:
          game.globals = parseGlobals(gameJson[key]);
          break;
        case Globals.PLAYER_KEY:
          game.player = parsePlayer(gameJson[key]);
          break;
        case Globals.PLATEAU_KEY:
          game.player.plateau = parsePlateau(gameJson[key], gameJson[Globals.CURRENT_ROOM_KEY]);
          break;
        case Globals.EVENTS_KEY:
          game.consumers = parseConsumers(gameJson[key]);
          break;
        case Globals.CURRENT_ROOM_KEY:
          break;
        default:
          print("wrong key found in json content : $key, will not be parsed");
          break;
      }
    }
    return game;
  }

  static List<GlobalVariable> parseGlobals(var globalsContent){
    if (globalsContent is Map) globalsContent = new List()..add(globalsContent);
    List<GlobalVariable> globals = new List();
    for (Map globalContent in globalsContent){
      if (globalContent[Globals.NAME_KEY] == null) {
        print("name of global not specified, will not be parsed");
        continue;
      }
      if (globalContent[Globals.VALUE_KEY] == null) {
        print("value of global not specified, will not be parsed");
        continue;
      }
      if (globalContent[Globals.TYPE_KEY] == null) {
        print("type of global not specified, will not be parsed");
        continue;
      }
      GlobalVariable global;
      switch (globalContent[Globals.TYPE_KEY].toLowerCase()){
        case "num":
          global = new NumGlobalVariable(globalContent['name'], globalContent['value']);
          break;
        case "string":
          global = new StringGlobalVariable(globalContent['name'], globalContent['value']);
          break;
        case "bool":
          global = new BooleanGlobalVariable(globalContent['name'], globalContent['value']);
          break;
        default:
          print("wrong type of global : ${globalsContent[Globals.TYPE_KEY]}, will not be parsed");
          break;
      }
      if (global != null) globals.add(global);
    }
    return globals;
  }

  static Player parsePlayer(var playerContent){
    if (!(playerContent is Map)){
      print("player is not formatted correctly, expected Map definition {}");
      return null;
    }
    Player player = new Player();
    for (String key in playerContent.keys){
      switch (key.toLowerCase()){
        case Globals.NAME_KEY:
          player.name = playerContent[key];
          break;
        case Globals.PROPERTIES_KEY:
          player.properties = parseProperties(playerContent[key]);
          break;
        case Globals.INVENTORY_KEY:
          player.inventory = parseInventory(playerContent[key]);
          break;
        case Globals.WEARING_KEY:
          player.wearing = parseWearing(playerContent[key]);
          break;
      }
    }
    return player;
  }

  static Map<String, BaseProperty> parseProperties(var propertiesContent){
    if (propertiesContent is Map) propertiesContent = new List()..add(propertiesContent);
    Map<String, BaseProperty> propertiesMap = new Map();
    for (Map propertyContent in propertiesContent){
      if (propertyContent[Globals.NAME_KEY] == null){
        print("name of property not specified, will not be parsed");
        continue;
      }
      if (propertyContent[Globals.TYPE_KEY] == null){
        print("type of property not specified, will not be parsed");
        continue;
      }
      if (propertyContent[Globals.VALUE_KEY] == null){
        print("value of property not specified, will not be parsed");
        continue;
      }
      BaseProperty property;
      switch (propertyContent[Globals.TYPE_KEY]){
        case "num":
          property = new NumProperty(propertyContent[Globals.NAME_KEY], propertyContent[Globals.DESCRIPTION_KEY], propertyContent[Globals.VALUE_KEY]);
          break;
        case "string":
          property = new StringProperty(propertyContent[Globals.NAME_KEY], propertyContent[Globals.DESCRIPTION_KEY], propertyContent[Globals.VALUE_KEY]);
          break;
        case "bool":
          property = new BoolProperty(propertyContent[Globals.NAME_KEY], propertyContent[Globals.DESCRIPTION_KEY], propertyContent[Globals.VALUE_KEY]);
          break;
        default:
          print("wrong type of property : ${propertyContent[Globals.TYPE_KEY]}, will not be parsed");
          break;
      }
      if (property != null) propertiesMap[property.name] = property;
    }
    return propertiesMap;
  }

  static List<BaseGameObject> parseInventory(var inventoryContent){
    if (inventoryContent is Map) inventoryContent = new List()..add(inventoryContent);
    List<BaseGameObject> inventory = new List();
    for (Map objectContent in inventoryContent){
      BaseGameObject object = parseObject(objectContent);
      if (object != null) inventory.add(object);
    }
    return inventory;
  }

  static BaseGameObject parseObject(var objectContent) {
    if (!(objectContent is Map)) {
      print("object is not formated correctly, will not be parsed. (Content not parsed : $objectContent)");
      return null;
    }
    if (objectContent[Globals.NAME_KEY] == null){
      print("name of object not specified, will not be parsed");
      return null;
    }
    BaseGameObject object;
    if (objectContent[Globals.TYPE_KEY] == null) objectContent[Globals.TYPE_KEY] = "base";
    switch(objectContent[Globals.TYPE_KEY]) {
      case "base":
        object = new BaseGameObject(0, objectContent[Globals.NAME_KEY], objectContent[Globals.DESCRIPTION_KEY]);
        break;
      case "wearable":
        object = new WearableGameObject.noModifier(0, objectContent[Globals.NAME_KEY], objectContent[Globals.DESCRIPTION_KEY]);
        break;
      case "consumable":
        object = new ConsumableGameObject.noModifier(0, objectContent[Globals.NAME_KEY], objectContent[Globals.DESCRIPTION_KEY]);
        break;
      default:
        print("wrong type of object : ${objectContent[Globals.TYPE_KEY]}, will not be parsed");
        break;
    }
    return object;
  }

  static List<WearableGameObject> parseWearing(var wearingContent){
    if (wearingContent is Map) wearingContent = new List()..add(wearingContent);
    List<WearableGameObject> wearing = new List();
    for (Map objectContent in wearingContent){
      if (objectContent[Globals.NAME_KEY] == null){
        print("name of object not specified, will not be parsed");
        continue;
      }
      if (objectContent[Globals.TYPE_KEY] != "wearable") {
        print("wrong type of object : ${objectContent[Globals.TYPE_KEY]}, \"wearable\" expected, will not be parsed");
        continue;
      }
      WearableGameObject object = new WearableGameObject.noModifier(0, objectContent[Globals.NAME_KEY], objectContent[Globals.DESCRIPTION_KEY]);
      wearing.add(object);
    }
    return wearing;
  }

  static Plateau parsePlateau(var plateauContent, var currentRoomId){
    if (plateauContent is Map) plateauContent = new List()..add(plateauContent);
    Plateau plateau;
    List<Room> rooms = new List();
    Map<Room, Map<Direction, num>> roomsLinksMap = new Map();
    for (Map roomContent in plateauContent) {
      if (roomContent[Globals.ID_KEY] == null) {
        print("id of room not specified, will not be parsed");
        continue;
      }
      if (roomContent[Globals.NAME_KEY] == null) {
        print("name of room not specified, will not be parsed");
        continue;
      }
      Room room = new Room(roomContent[Globals.ID_KEY].hashCode, roomContent[Globals.NAME_KEY], roomContent[Globals.DESCRIPTION_KEY]);
      List<BaseGameObject> objects = new List();
      var objectsContent = roomContent[Globals.OBJECTS_KEY];
      if (objectsContent != null){
        if (objectsContent is Map) objectsContent = new List()..add(objectsContent);
        for (Map objectContent in objectsContent){
          BaseGameObject object = parseObject(objectContent);
          if (object != null) objects.add(object);
        }
      }
      room.objects = objects;
      room.nextRooms = new Map();
      var nextRoomsContent = roomContent[Globals.DIRECTION_KEY];
      if (nextRoomsContent != null) {
        if (!(nextRoomsContent is Map))
          print("direction not correctly formated, expecting Map definition {}");
        else {
          Map<Direction, num> tempDirections = new Map();
          for (String key in nextRoomsContent.keys) {
            Direction dir = parseDirection(key);
            if (dir != null)
              tempDirections[dir] = nextRoomsContent[key].hashCode;
          }
          if (tempDirections.keys.length != 0)
            roomsLinksMap[room] = tempDirections;
        }
      }
      rooms.add(room);
    }
    plateau = new Plateau(linkRooms(rooms, roomsLinksMap));
    if (currentRoomId != null) {
      for (Room comparedRoom in plateau.rooms){
        if (currentRoomId.hashCode == comparedRoom.id){
          plateau.currentRoom = comparedRoom;
          break;
        }
      }
      if (plateau.currentRoom == null)
        print("warning, the room id specified by currentRoomId is not existent");
    }
    if (plateau.currentRoom == null) {
      print("current room set to the fisrt in the list of rooms");
      plateau.currentRoom = plateau.getRooms()[0];
    }
    return plateau;
  }

  static Direction parseDirection(var directionContent){
    if (!(directionContent is String)){
      print("direction key is not a string : $directionContent, will not be parsed");
      return null;
    }
    Direction direction;
    switch ((directionContent as String).toLowerCase().replaceAll(new RegExp("_-"), '')){
      case "north":
      case "n":
        direction = Direction.NORTH;
        break;
      case "south":
      case "s":
        direction = Direction.SOUTH;
        break;
      case "west":
      case "w":
        direction = Direction.WEST;
        break;
      case "east":
      case "e":
        direction = Direction.EAST;
        break;
      case "northwest":
      case "nw":
        direction = Direction.NORTH_WEST;
        break;
      case "northeast":
      case "ne":
        direction = Direction.NORTH_EAST;
        break;
      case "southwest":
      case "sw":
        direction = Direction.SOUTH_WEST;
        break;
      case "southeast":
      case "se":
        direction = Direction.SOUTH_EAST;
        break;
      case "up":
      case "u":
        direction = Direction.UP;
        break;
      case "down":
      case "d":
        direction = Direction.DOWN;
        break;
      default:
        print("direction key is not an expected direction : $directionContent, will not be parsed");
    }
    return direction;
  }

  static List<Room> linkRooms(List<Room> rooms, Map<Room, Map<Direction, num>> linkingMap) {
    List<Room> linkedRooms = new List();
    for (Room room in linkingMap.keys) {
      Map<Direction, Room> nextRooms = new Map();
      for (Direction dirKey in linkingMap[room].keys) {
        Room linkRoom;
        for (Room comparedRoom in rooms) {
          if (comparedRoom.id == linkingMap[room][dirKey]) {
            linkRoom = comparedRoom;
            break;
          }
        }
        if (linkRoom == null) {
          print("warning, room id not existent, the link will not be parsed");
          continue;
        } else {
          nextRooms[dirKey] = linkRoom;
        }
      }
      room.nextRooms = nextRooms;
      linkedRooms.add(room);
    }
    return linkedRooms;
  }

  static List<EventConsumer> parseConsumers(var consumersContent){
    if (consumersContent is Map) consumersContent = new List()..add(consumersContent);
    List<EventConsumer> consumers = new List();
    for (Map consumerContent in consumersContent){
      if (consumerContent[Globals.LISTEN_KEY] == null){
        print("listenTo key not specified, will not be parsed");
        continue;
      }
      if (consumerContent[Globals.STOP_EVENT_KEY] == null)
        consumerContent[Globals.STOP_EVENT_KEY] = false;
      if (consumerContent[Globals.ANY_CONDITION_KEY] == null)
        consumerContent[Globals.ANY_CONDITION_KEY] = false;
      if (consumerContent[Globals.CONDITIONS_KEY] == null)
        consumerContent[Globals.CONDITIONS_KEY] = new List();
      if (consumerContent[Globals.CONDITIONS_KEY].length == 0)
        print("warning, event consumer without conditions, will consume each event it listens to");
      if (consumerContent[Globals.APPLY_KEY] == null || consumerContent[Globals.APPLY_KEY].length == 0) {
        print("no apply in event, event doing nothing, no parsing");
        continue;
      }
      CustomizableEventConsumer consumer = new CustomizableEventConsumer(consumerContent[Globals.LISTEN_KEY], consumerContent[Globals.STOP_EVENT_KEY], consumerContent[Globals.ANY_CONDITION_KEY]);
      for (String condition in consumerContent[Globals.CONDITIONS_KEY]){
        consumer.conditions.add(new StoredCondition.fromString(consumer, condition));
      }
      for (String operation in consumerContent[Globals.APPLY_KEY]){
        consumer.operations.add(new StoredOperation.fromString(operation));
      }
      consumers.add(consumer);
    }
    return consumers;
  }

}