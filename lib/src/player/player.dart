part of proto_game.player;

class Player implements ExposedAPI, HasProperties {

  String name = "Player";

  Plateau plateau;

  Map<String, BaseProperty> properties = new Map();

  List<BaseGameObject> inventory = new List();

  List<WearableGameObject> wearing = new List();

  Map<String, dynamic> exposeAPI() {
    return properties;
  }

  BaseProperty getProperty(String name) => properties[name];

  BaseProperty getFinalProperty(String name){
    if (properties[name] == null){
      print("Wrong name, property $name does not exist");
      return null;
    }
    return new ModifiedProperty(properties[name], wearing, this);
  }

  bool move(Direction direction){
    return plateau.move(direction);
  }
}
