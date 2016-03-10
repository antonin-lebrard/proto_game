part of proto_game.room;

abstract class Room {

  num id;

  String name;

  Room(this.id, this.name);

  String getDescription();

  List<BaseGameObject> getObjects();

  Map<Direction, Room> getNextRooms();

  /**
   * Move to the room in the direction passed.
   * True is successful, False otherwise.
   */
  bool move(Direction direction);

}