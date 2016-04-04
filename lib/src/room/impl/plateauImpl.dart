part of proto_game.room;

class SimplePlateauImpl extends Plateau {

  Room currentRoom;

  List<Room> rooms;

  List<GameCounter> gameCounters = new List();

  SimplePlateauImpl(this.rooms);

  List<Room> getRooms() => rooms;

  bool move(Direction direction) {
    if (currentRoom.move(direction)){
      currentRoom = currentRoom.getNextRooms()[direction];
      gameLoop();
      return true;
    }
    return false;
  }

  void gameLoop() {
    gameCounters.forEach((GameCounter g){
      g.gameLoop();
    });
  }

}