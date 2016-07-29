part of proto_game.events;


class EventMappings {

  static Map<Type, Map<String, dynamic>> eventMappings = {
    MoveEvent : {
      "params": { "from": Room, "to": Room },
      "name": "move",
    },
    TakeEvent : {
      "params": { "object": BaseGameObject },
      "name": "take",
    },
    DropEvent : {
      "params": { "object": BaseGameObject },
      "name": "drop",
    },
    WearEvent : {
      "params": { "object": WearableGameObject },
      "name": "wear",
    },
    RemoveEvent : {
      "params": { "object": WearableGameObject },
      "name": "remove",
    },
    UseEvent : {
      "params": { "object": BaseGameObject },
      "name": "use",
    },
  };

}


abstract class Event {

  Map<String, Object> properties = new Map();

  Event();

  _setProperties(Map<String, Object> properties) => this.properties = properties;

}

class MoveEvent extends Event {
  Room from, to;
  MoveEvent(this.from, this.to) {
    _setProperties({"from":from, "to":to});
  }
}

class TakeEvent extends Event {
  BaseGameObject object;
  TakeEvent(this.object){
    _setProperties({"object":object});
  }
}

class DropEvent extends Event {
  BaseGameObject object;
  DropEvent(this.object){
    _setProperties({"object":object});
  }
}

class WearEvent extends Event {
  WearableGameObject object;
  WearEvent(this.object){
    _setProperties({"object":object});
  }
}

class RemoveEvent extends Event {
  WearableGameObject object;
  RemoveEvent(this.object){
    _setProperties({"object":object});
  }
}

class UseEvent extends Event {
  BaseGameObject object;
  UseEvent(this.object){
    _setProperties({"object":object});
  }
}