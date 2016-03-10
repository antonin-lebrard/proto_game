part of proto_game.player;

class BasePlayer {

  String name = "Player";

  Map<String, BaseProperty> _mapGlobalProperties;

  List<BaseGameObject> inventory;

  List<WearableGameObject> wearing;

  BaseProperty getProperty(String name){
    if (_mapGlobalProperties[name] == null){
      print("Wrong name, property $name does not exist");
      return null;
    }
    return new ModifiedProperty(_mapGlobalProperties[name], wearing);
  }

}