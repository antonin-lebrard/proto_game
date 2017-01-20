part of proto_game.room;

class Room implements ExposedAPI, HasDescription, HasId {

  String name_id;

  String displayName;

  String description;

  List<BaseGameObject> objects;

  List<Npc> npcs;

  Map<String, BaseProperty> properties;

  Map<Direction, Room> nextRooms;

  Room(this.name_id, this.displayName, this.description, this.properties);

  String getDescription() => description;

  String getId() => name_id;

  List<BaseGameObject> getObjects() => objects;

  Map<Direction, Room> getNextRooms() => nextRooms;

  bool canMove(Direction direction){
    if (nextRooms[direction] == null)
      return false;
    return true;
  }

  Map<String, dynamic> exposeAPI() {
    return { name_id : new Map<String, dynamic>()
                        ..addAll(properties)
                        ..putIfAbsent("name", () => displayName)
                        ..putIfAbsent("object", () => this)
    };
  }
}