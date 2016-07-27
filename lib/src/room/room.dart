part of proto_game.room;

class Room {

  int id;

  String name;

  String description;

  List<BaseGameObject> objects;

  Map<Direction, Room> nextRooms;

  Room(this.id, this.name, this.description);

  String getDescription() => description;

  List<BaseGameObject> getObjects() => objects;

  Map<Direction, Room> getNextRooms() => nextRooms;

  bool move(Direction direction){
    if (nextRooms[direction] == null)
      return false;
    return true;
  }

}