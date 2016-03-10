part of proto_game.room;

class SimpleRoomImpl extends Room {

  String description;

  List<BaseGameObject> objects;

  Map<Direction, Room> nextRooms;

  SimpleRoomImpl(num id, String name, this.description)
    : super(id, name)
  {}

  String getDescription() => description;

  List<BaseGameObject> getObjects() => objects;

  Map<Direction, Room> getNextRooms() => nextRooms;

  bool move(Direction direction){
    if (nextRooms[direction] == null)
      return false;
    return true;
  }

}