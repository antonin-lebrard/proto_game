part of proto_game.room;

class Plateau {

  Room currentRoom;

  List<Room> rooms;

  List<GameCounter> gameCounters = new List();

  Plateau(this.rooms);

  List<Room> getRooms() => rooms;

  Room getCurrentRoom() => currentRoom;

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