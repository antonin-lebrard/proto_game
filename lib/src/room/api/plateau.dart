part of proto_game.room;

abstract class Plateau {

  List<Room> getRooms();

  Room getCurrentRoom();

  bool move(Direction direction);

  void gameLoop();

}