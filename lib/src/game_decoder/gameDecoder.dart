part of proto_game.gameDecoder;

abstract class GameDecoderBase {

  String writeToFormat();

  readFromFormat(String content);

}

class GameDecoderJSON extends GameDecoderBase {

  @override
  String writeToFormat(){return "null";}

  @override
  readFromFormat(String content){
    Map<String, dynamic> gameJson = JSON.decode(content)["game"];
    Game game = new Game();
    for (String key in gameJson){
      switch(key.toLowerCase()){
        case "globals":
          game.globals = parseGlobals(gameJson[key]);
          break;
        case "player":
          game.player = parsePlayer(gameJson[key]);
          break;
        case "rooms":
          break;
        default:
          print("wrong key found in json content : $key, will not be parsed");
          break;
      }
    }
  }

  List<GlobalVariable> parseGlobals(var globalsContent){
    if (globalsContent is Map) globalsContent = new List()..add(globalsContent);
    List<GlobalVariable> globals = new List();
    for (Map globalContent in globalsContent){
      if (globalContent['name'] == null) {
        print("name of global not specified, will not be parsed");
        continue;
      }
      if (globalContent['value'] == null) {
        print("value of global not specified, will not be parsed");
        continue;
      }
      if (globalContent['type'] == null) {
        print("type of global not specified, will not be parsed");
        continue;
      }
      GlobalVariable global;
      switch (globalContent['type'].toLowerCase()){
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
          print("wrong type of global : ${globalsContent["type"]}, will not be parsed");
          break;
      }
      if (global != null) globals.add(global);
    }
    return globals;
  }

  Player parsePlayer(var playerContent){
    if (!playerContent is Map){
      print("player is not formatted correctly, expected Map definition {}");
      return null;
    }
    Player player = new Player();
    for (String key in playerContent){
      switch (key.toLowerCase()){
        case "name":
          player.name = playerContent[key];
          break;
        case "properties":
          player.mapGlobalProperties = parseProperties(playerContent[key]);
          break;
        case "inventory":
          player.inventory = parseInventory(playerContent[key]);
          break;
        case "wearing":
          player.wearing = parseWearing(playerContent[key]);
          break;
      }
    }
    return player;
  }

  Map<String, BaseProperty> parseProperties(var propertiesContent){
    if (propertiesContent is Map) propertiesContent = new List()..add(propertiesContent);
    Map<String, BaseProperty> propertiesMap = new Map();
    for (Map propertyContent in propertiesContent){
      if (propertyContent['name'] == null){
        print("name of property not specified, will not be parsed");
        continue;
      }
      if (propertyContent['type'] == null){
        print("type of property not specified, will not be parsed");
        continue;
      }
      if (propertyContent['value'] == null){
        print("value of property not specified, will not be parsed");
        continue;
      }
      BaseProperty property;
      switch (propertyContent['type']){
        case "num":
          property = new NumProperty(propertyContent['name'], propertyContent['description'], propertyContent['value']);
          break;
        case "string":
          property = new StringProperty(propertyContent['name'], propertyContent['description'], propertyContent['value']);
          break;
        case "bool":
          property = new BoolProperty(propertyContent['name'], propertyContent['description'], propertyContent['value']);
          break;
        default:
          print("wrong type of property : ${propertyContent["type"]}, will not be parsed");
          break;
      }
      if (property != null) propertiesMap[property.name] = property;
    }
    return propertiesMap;
  }

  List<BaseGameObject> parseInventory(var inventoryContent){
    if (inventoryContent is Map) inventoryContent = new List()..add(inventoryContent);
    List<BaseGameObject> inventory = new List();
    for (Map objectContent in inventoryContent){
      if (objectContent['name'] == null){
        print("name of object not specified, will not be parsed");
        continue;
      }
      BaseGameObject object;
      if (objectContent['type'] == null) objectContent['type'] = "base";
      switch(objectContent['type']) {
        case "base":
          object = new BaseGameObject(0, objectContent['name'], objectContent['description']);
          break;
        case "wearable":
          object = new WearableGameObject.noModifier(0, objectContent['name'], objectContent['description']);
          break;
        case "consumable":
          object = new ConsumableGameObject.noModifier(0, objectContent['name'], objectContent['description']);
          break;
        default:
          print("wrong type of object : ${objectContent["type"]}, will not be parsed");
          break;
      }
      if (object != null) inventory.add(object);
    }
    return inventory;
  }

  List<WearableGameObject> parseWearing(var wearingContent){
    if (wearingContent is Map) wearingContent = new List()..add(wearingContent);
    List<WearableGameObject> wearing = new List();
    for (Map objectContent in wearingContent){
      if (objectContent['name'] == null){
        print("name of object not specified, will not be parsed");
        continue;
      }
      if (objectContent['type'] != "wearable") {
        print("wrong type of object : ${objectContent['type']}, \"wearable\" expected, will not be parsed");
        continue;
      }
      WearableGameObject object = new WearableGameObject.noModifier(0, objectContent['name'], objectContent['description']);
      wearing.add(object);
    }
    return wearing;
  }

}