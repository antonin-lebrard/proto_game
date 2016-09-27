part of proto_game.room;

class Room extends HasDescription {

  int id;

  String name;

  String description;

  List<BaseGameObject> objects;

  List<Npc> npcs;

  Map<String, BaseProperty> properties;

  Map<Direction, Room> nextRooms;

  Room(this.id, this.name, this.description, this.properties);

  String getDescription() => description;

  List<BaseGameObject> getObjects() => objects;

  Map<Direction, Room> getNextRooms() => nextRooms;

  bool canMove(Direction direction){
    if (nextRooms[direction] == null)
      return false;
    return true;
  }

}