part of proto_game.gameDecoder;

/**
 * Decode/Encode a game from a format.
 * Implementations:
 *  - [GameDecoderJSON] for JSON.
 *  - maybe others later.
 */
abstract class GameDecoderBase {
  String writeToFormat();
  Game readFromFormat(String content, LowLevelIo io);
}

class GameDecoderJSON extends GameDecoderBase {

  static List<Function> _toExecuteAtTheEnd = new List();

  String writeToFormat(){return "null";}

  Game readFromFormat(String content, LowLevelIo io){
    Map<String, dynamic> gameJson = JSON.decode(content)["game"];
    Game game = new Game(io);
    if (gameJson[Globals.GLOBALS_KEY] != null) game.globals = parseGlobals(gameJson[Globals.GLOBALS_KEY]);
    if (gameJson[Globals.OBJECTS_KEY] != null) game.objectStorage = parseObjects(gameJson[Globals.OBJECTS_KEY]);
    if (gameJson[Globals.NPCS_KEY]    != null) game.npcStorage = parseNpcs(gameJson[Globals.NPCS_KEY]);
    if (gameJson[Globals.INTERACTION_CHOICES_KEY] != null) game.interactionChoicesStorage = parseInteractionChoices(gameJson[Globals.INTERACTION_CHOICES_KEY]);
    if (gameJson[Globals.EVENTS_KEY]  != null) game.consumers = parseConsumers(gameJson[Globals.EVENTS_KEY]);
    if (gameJson[Globals.PLAYER_KEY]  != null) game.player = parsePlayer(gameJson[Globals.PLAYER_KEY]);
    if (gameJson[Globals.PLATEAU_KEY] != null) game.player.plateau = parsePlateau(gameJson[Globals.PLATEAU_KEY], gameJson[Globals.CURRENT_ROOM_KEY]);
    for (String key in gameJson.keys){
      switch(key){
        case Globals.GLOBALS_KEY:
        case Globals.PLAYER_KEY:
        case Globals.PLATEAU_KEY:
        case Globals.EVENTS_KEY:
        case Globals.TITLE_KEY:
        case Globals.VERSION_KEY:
        case Globals.CURRENT_ROOM_KEY:
        case Globals.OBJECTS_KEY:
        case Globals.NPCS_KEY:
        case Globals.INTERACTION_CHOICES_KEY:
          break;
        default:
          print("wrong key found in json content : $key, will not be parsed");
          break;
      }
    }
    game.initAPI();
    for (Function f in _toExecuteAtTheEnd){
      f();
    }
    _toExecuteAtTheEnd.clear();
    return game;
  }

  static List<GlobalVariable> parseGlobals(var globalsContent){
    globalsContent = GameDecoderHelper.toListSupportingMap(globalsContent);
    List<GlobalVariable> globals = new List();
    for (Map globalContent in globalsContent){
      if (!GameDecoderHelper.isMandatoryKeysPresent(globalContent, [Globals.NAME_KEY, Globals.VALUE_KEY, Globals.TYPE_KEY]))
        continue;
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
          player.wearing = parseInventory(playerContent[key]);
          break;
      }
    }
    return player;
  }

  static Map<String, BaseProperty> parseProperties(var propertiesContent){
    propertiesContent = GameDecoderHelper.toListSupportingMap(propertiesContent);
    Map<String, BaseProperty> propertiesMap = new Map();
    for (Map propertyContent in propertiesContent){
      if (!GameDecoderHelper.isMandatoryKeysPresent(propertyContent, [Globals.NAME_KEY, Globals.VALUE_KEY, Globals.TYPE_KEY]))
        continue;
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
    inventoryContent = GameDecoderHelper.toListSupportingString(inventoryContent);
    List<BaseGameObject> inventory = new List();
    for (String objectId in inventoryContent){
      BaseGameObject object = Game.game.getObjectById(objectId);
      if (object != null) inventory.add(object);
    }
    return inventory;
  }

  static BaseGameObject parseObject(var objectContent) {
    if (!(objectContent is Map)) {
      print("object is not formated correctly, will not be parsed. (Content not parsed : $objectContent)");
      return null;
    }
    if (!GameDecoderHelper.isMandatoryKeyPresent(objectContent, Globals.ID_KEY))
      return null;
    BaseGameObject object;
    // TODO : wrong !!
    objectContent[Globals.PROPERTIES_KEY] = GameDecoderHelper.toListSupportingMap(objectContent[Globals.PROPERTIES_KEY]);
    objectContent[Globals.PROPERTIES_KEY] = parseProperties(objectContent[Globals.PROPERTIES_KEY]);
    objectContent[Globals.NAME_KEY] = objectContent[Globals.NAME_KEY] ?? objectContent[Globals.ID_KEY];
    if (objectContent.containsKey(Globals.MODIFIER_KEY)) objectContent[Globals.MODIFIER_KEY] = parseModifier(objectContent[Globals.MODIFIER_KEY]);
    if (objectContent[Globals.TYPE_KEY] == null) objectContent[Globals.TYPE_KEY] = "base";
    switch(objectContent[Globals.TYPE_KEY]) {
      case "base":
        object = new BaseGameObject(
            objectContent[Globals.ID_KEY],
            objectContent[Globals.NAME_KEY],
            objectContent[Globals.DESCRIPTION_KEY],
            objectContent[Globals.PROPERTIES_KEY]);
        break;
      case "wearable":
        if (objectContent.containsKey(Globals.MODIFIER_KEY))
          object = new WearableGameObject(
              objectContent[Globals.ID_KEY],
              objectContent[Globals.NAME_KEY],
              objectContent[Globals.DESCRIPTION_KEY],
              objectContent[Globals.PROPERTIES_KEY],
              objectContent[Globals.MODIFIER_KEY]);
        else
          object = new WearableGameObject.noModifier(
              objectContent[Globals.ID_KEY],
              objectContent[Globals.NAME_KEY],
              objectContent[Globals.DESCRIPTION_KEY],
              objectContent[Globals.PROPERTIES_KEY]);
        break;
      case "consumable":
        if (objectContent.containsKey(Globals.MODIFIER_KEY))
          object = new ConsumableGameObject(
              objectContent[Globals.ID_KEY],
              objectContent[Globals.NAME_KEY],
              objectContent[Globals.DESCRIPTION_KEY],
              objectContent[Globals.PROPERTIES_KEY],
              objectContent[Globals.MODIFIER_KEY]);
        else
          object = new ConsumableGameObject.noModifier(
              objectContent[Globals.ID_KEY],
              objectContent[Globals.NAME_KEY],
              objectContent[Globals.DESCRIPTION_KEY],
              objectContent[Globals.PROPERTIES_KEY]);
        break;
      default:
        print("wrong type of object : ${objectContent[Globals.TYPE_KEY]}, will not be parsed");
        break;
    }
    return object;
  }

  static Modifier parseModifier(var modifiersContent){
    modifiersContent = GameDecoderHelper.toListSupportingMap(modifiersContent);
    CustomModifier modifier = new CustomModifier();
    for (Map modifierContent in modifiersContent){
      modifierContent[modifierContent.keys.first] = "context.${modifierContent.keys.first}+=${modifierContent[modifierContent.keys.first]}";
      StoredOperation modifierOp = new StoredOperation.fromString(modifierContent[modifierContent.keys.first]);
      modifier.modifiers.putIfAbsent(modifierContent.keys.first, () => modifierOp);
    }
    return modifier;
  }

  static Plateau parsePlateau(var plateauContent, var currentRoomId){
    plateauContent = GameDecoderHelper.toListSupportingMap(plateauContent);
    Plateau plateau;
    List<Room> rooms = new List();
    Map<Room, Map<Direction, String>> roomsLinksMap = new Map();
    for (Map roomContent in plateauContent) {
      if (!GameDecoderHelper.isMandatoryKeysPresent(roomContent, [Globals.ID_KEY, Globals.NAME_KEY]))
        continue;
      roomContent[Globals.PROPERTIES_KEY] = GameDecoderHelper.toListSupportingMap(roomContent[Globals.PROPERTIES_KEY]);
      roomContent[Globals.PROPERTIES_KEY] = parseProperties(roomContent[Globals.PROPERTIES_KEY]);
      Room room = new Room(roomContent[Globals.ID_KEY], roomContent[Globals.NAME_KEY], roomContent[Globals.DESCRIPTION_KEY], roomContent[Globals.PROPERTIES_KEY]);
      List<BaseGameObject> objects = new List();
      var objectsContent = GameDecoderHelper.toListSupportingString(roomContent[Globals.OBJECTS_KEY]);
      for (String objectId in objectsContent){
        BaseGameObject object = Game.game.getObjectById(objectId);
        if (object != null) objects.add(object);
      }
      room.objects = objects;
      List<Npc> npcs = new List();
      var npcsContent = GameDecoderHelper.toListSupportingString(roomContent[Globals.NPCS_KEY]);
      for (String npcId in npcsContent){
        Npc npc = Game.game.getNpcById(npcId);
        if (npc != null) npcs.add(npc);
      }
      room.npcs = npcs;
      room.nextRooms = new Map();
      var nextRoomsContent = roomContent[Globals.DIRECTION_KEY];
      if (nextRoomsContent != null) {
        if (!(nextRoomsContent is Map))
          print("directions not correctly formated, expecting Map definition {}");
        else {
          Map<Direction, String> tempDirections = new Map();
          for (String key in nextRoomsContent.keys) {
            Direction dir = parseDirection(key);
            if (dir != null)
              tempDirections[dir] = nextRoomsContent[key];
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
        if (currentRoomId == comparedRoom.name_id){
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
      case "north-west":
      case "north_west":
      case "nw":
        direction = Direction.NORTH_WEST;
        break;
      case "northeast":
      case "north-east":
      case "north_east":
      case "ne":
        direction = Direction.NORTH_EAST;
        break;
      case "southwest":
      case "south-west":
      case "south_west":
      case "sw":
        direction = Direction.SOUTH_WEST;
        break;
      case "southeast":
      case "south-east":
      case "south_east":
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

  static List<Room> linkRooms(List<Room> rooms, Map<Room, Map<Direction, String>> linkingMap) {
    List<Room> linkedRooms = new List();
    for (Room room in linkingMap.keys) {
      Map<Direction, Room> nextRooms = new Map();
      for (Direction dirKey in linkingMap[room].keys) {
        Room linkRoom;
        for (Room comparedRoom in rooms) {
          if (comparedRoom.name_id == linkingMap[room][dirKey]) {
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
    consumersContent = GameDecoderHelper.toListSupportingMap(consumersContent);
    List<EventConsumer> consumers = new List();
    for (Map consumerContent in consumersContent){
      if (!GameDecoderHelper.isMandatoryKeyPresent(consumerContent, Globals.LISTEN_KEY))
        continue;
      if (consumerContent[Globals.STOP_EVENT_KEY] == null) consumerContent[Globals.STOP_EVENT_KEY] = false;
      if (consumerContent[Globals.ANY_CONDITION_KEY] == null) consumerContent[Globals.ANY_CONDITION_KEY] = false;
      consumerContent[Globals.CONDITIONS_KEY] = GameDecoderHelper.toListSupportingString(consumerContent[Globals.CONDITIONS_KEY]);
      consumerContent[Globals.APPLY_KEY] = GameDecoderHelper.toListSupportingString(consumerContent[Globals.APPLY_KEY]);
      if (consumerContent[Globals.CONDITIONS_KEY].length == 0)
      print("warning, event consumer without conditions, will consume each event it listens to");
      if (consumerContent[Globals.APPLY_KEY].length == 0)
        print("no apply in event, event doing nothing, maybe not a good idea");
      consumerContent[Globals.TEXT_KEY] = GameDecoderHelper.toStringSupportingList(consumerContent[Globals.TEXT_KEY]);
      CustomizableEventConsumer consumer = new CustomizableEventConsumer(
          consumerContent[Globals.LISTEN_KEY],
          text: consumerContent[Globals.TEXT_KEY],
          stopEvent: consumerContent[Globals.STOP_EVENT_KEY],
          anyConditions: consumerContent[Globals.ANY_CONDITION_KEY]
      );
      _toExecuteAtTheEnd.add((){
        for (String condition in consumerContent[Globals.CONDITIONS_KEY]){
          consumer.conditions.add(new StoredCondition.fromString(consumer.listenTo, condition));
        }
        for (String operation in consumerContent[Globals.APPLY_KEY]){
          consumer.operations.add(new StoredOperation.fromString(operation));
        }
      });
      consumers.add(consumer);
    }
    return consumers;
  }

  static SplayTreeMap<num, BaseGameObject> parseObjects(var objectsContent){
    objectsContent = GameDecoderHelper.toListSupportingMap(objectsContent);
    SplayTreeMap<num, BaseGameObject> map = new SplayTreeMap<num, BaseGameObject>();
    for (Map objectContent in objectsContent){
      BaseGameObject object = parseObject(objectContent);
      if (object != null)
        map[object.name_id.hashCode] = object;
    }
    return map;
  }

  static SplayTreeMap<num, Npc> parseNpcs(var npcsContent){
    npcsContent = GameDecoderHelper.toListSupportingMap(npcsContent);
    SplayTreeMap<num, Npc> npcs = new SplayTreeMap<num, Npc>();
    for (Map npcContent in npcsContent){
      Npc npc = parseNpc(npcContent);
      if (npc != null)
        npcs[npc.name_id.hashCode] = npc;
    }
    return npcs;
  }

  static Npc parseNpc(Map npcContent){
    if (!GameDecoderHelper.isMandatoryKeyPresent(npcContent, Globals.ID_KEY))
      return null;
    Npc npc = new Npc();
    npc.name_id = npcContent[Globals.ID_KEY];
    npc.displayName = npcContent[Globals.NAME_KEY] ?? npcContent[Globals.ID_KEY];
    npcContent[Globals.PROPERTIES_KEY] = GameDecoderHelper.toListSupportingMap(npcContent[Globals.PROPERTIES_KEY]);
    npc.properties = parseProperties(npcContent[Globals.PROPERTIES_KEY]);
    npcContent[Globals.INVENTORY_KEY] = GameDecoderHelper.toListSupportingString(npcContent[Globals.INVENTORY_KEY]);
    npc.inventory = parseInventory(npcContent[Globals.INVENTORY_KEY]);
    npcContent[Globals.WEARING_KEY] = GameDecoderHelper.toListSupportingString(npcContent[Globals.WEARING_KEY]);
    npc.wearing = parseInventory(npcContent[Globals.WEARING_KEY]);
    if (npcContent[Globals.INTERACTIONS_KEY] == null) {
      npcContent[Globals.INTERACTIONS_KEY] = new List();
      print("no interactions with npc ${npcContent[Globals.NAME_KEY]}, possible mistake");
    }
    List<NpcInteraction> interactions = new List();
    for (Map interactionContent in npcContent[Globals.INTERACTIONS_KEY]){
      NpcInteraction interaction = parseInteraction(interactionContent);
      if (interaction != null)
        interactions.add(interaction);
    }
    npc.interactions = interactions;
    return npc;
  }

  static NpcInteraction parseInteraction(Map interactionContent){
    if (!GameDecoderHelper.isMandatoryKeyPresent(interactionContent, Globals.ACTION_NAME_KEY))
      return null;
    if (interactionContent[Globals.ANY_CONDITION_KEY] == null) interactionContent[Globals.ANY_CONDITION_KEY] = false;
    interactionContent[Globals.CONDITIONS_KEY] = GameDecoderHelper.toListSupportingString(interactionContent[Globals.CONDITIONS_KEY]);
    interactionContent[Globals.APPLY_KEY] = GameDecoderHelper.toListSupportingString(interactionContent[Globals.APPLY_KEY]);
    if (interactionContent[Globals.CONDITIONS_KEY].length == 0)
      print("warning, event consumer without conditions, will consume each event it listens to");
    interactionContent[Globals.TEXT_KEY] = GameDecoderHelper.toStringSupportingList(interactionContent[Globals.TEXT_KEY]);
    NpcInteraction interaction = new NpcInteraction(
        interactionContent[Globals.ACTION_NAME_KEY],
        anyConditions: interactionContent[Globals.ANY_CONDITION_KEY],
        text: interactionContent[Globals.TEXT_KEY],
    );
    _toExecuteAtTheEnd.add((){
      for (String condition in interactionContent[Globals.CONDITIONS_KEY]){
        interaction.conditions.add(new StoredCondition.fromString(null, condition));
      }
      for (String operation in interactionContent[Globals.APPLY_KEY]){
        interaction.operations.add(new StoredOperation.fromString(operation));
      }
    });
    return interaction;
  }

  static SplayTreeMap<num, InteractionChoice> parseInteractionChoices(var interactionChoicesContent){
    interactionChoicesContent = GameDecoderHelper.toListSupportingMap(interactionChoicesContent);
    SplayTreeMap<num, InteractionChoice> interactionChoices = new SplayTreeMap<num, InteractionChoice>();
    for (var interactionChoiceContent in interactionChoicesContent){
      InteractionChoice choice = parseInteractionChoice(interactionChoiceContent);
      if (choice != null)
        interactionChoices[choice.id.hashCode] = choice;
    }
    return interactionChoices;
  }

  static InteractionChoice parseInteractionChoice(Map interactionChoiceContent){
    if (!GameDecoderHelper.isMandatoryKeyPresent(interactionChoiceContent, Globals.ID_KEY))
      return null;
    interactionChoiceContent[Globals.CHOICES_KEY] = GameDecoderHelper.toListSupportingMap(interactionChoiceContent[Globals.CHOICES_KEY]);
    if (interactionChoiceContent[Globals.WITH_CANCEL_KEY] == null)
      interactionChoiceContent[Globals.WITH_CANCEL_KEY] = true;
    if (interactionChoiceContent[Globals.WITH_CANCEL_KEY] == false && interactionChoiceContent[Globals.CHOICES_KEY].isEmpty){
      print("Must have a choice if cancel choice is not present. Will block user.");
      return null;
    }
    InteractionChoice interactionChoice = new InteractionChoice(interactionChoiceContent[Globals.ID_KEY]);
    List<Choice> choices = new List<Choice>();
    for (Map choiceContent in interactionChoiceContent[Globals.CHOICES_KEY]){
      Choice choice = parseChoice(choiceContent);
      if (choice != null)
        choices.add(choice);
    }
    if (interactionChoiceContent[Globals.WITH_CANCEL_KEY])
      choices.add(new Choice.cancel());
    interactionChoice.choices = choices;
    return interactionChoice;
  }

  static Choice parseChoice(Map choiceContent){
    if (!GameDecoderHelper.isMandatoryKeyPresent(choiceContent, Globals.NAME_KEY))
      return null;
    choiceContent[Globals.APPLY_KEY] = GameDecoderHelper.toListSupportingString(choiceContent[Globals.APPLY_KEY]);
    Choice choice = new Choice(choiceContent[Globals.NAME_KEY], choiceContent[Globals.TEXT_KEY]);
    _toExecuteAtTheEnd.add((){
      for (String applyContent in choiceContent[Globals.APPLY_KEY]){
        choice.operations.add(new StoredOperation.fromString(applyContent));
      }
    });
    return choice;
  }

}