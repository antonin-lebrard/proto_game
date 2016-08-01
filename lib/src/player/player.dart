part of proto_game.player;

class Player {

  String name = "Player";

  Plateau plateau;

  Map<String, BaseProperty> properties = new Map();

  List<BaseGameObject> inventory = new List();

  List<WearableGameObject> wearing = new List();

  BaseProperty getProperty(String name){
    if (properties[name] == null){
      print("Wrong name, property $name does not exist");
      return null;
    }
    return new ModifiedProperty(properties[name], wearing);
  }

  bool move(Direction direction){
    if (new EventsManager().emitEvent(new MoveEvent(plateau.getCurrentRoom(), plateau.getCurrentRoom().getNextRooms()[direction]))) {
      if (plateau.move(direction)) {
        return true;
      }
      return false;
    }
    return false;
  }
}