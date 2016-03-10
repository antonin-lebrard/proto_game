part of proto_game.room;

abstract class Plateau {

  List<Room> getRooms();

  bool move(Direction direction);

  void gameLoop();

}