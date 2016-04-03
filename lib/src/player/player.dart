part of proto_game.player;

class BasePlayer {

  String name = "Player";

  Map<String, BaseProperty> mapGlobalProperties = new Map();

  List<BaseGameObject> inventory = new List();

  List<WearableGameObject> wearing = new List();

  BaseProperty getProperty(String name){
    if (mapGlobalProperties[name] == null){
      print("Wrong name, property $name does not exist");
      return null;
    }
    return new ModifiedProperty(mapGlobalProperties[name], wearing);
  }

}

class Player extends BasePlayer {

}