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

  Event();

}

class MoveEvent extends Event {
  Room from, to;
  MoveEvent(this.from, this.to);
}

class TakeEvent extends Event {
  BaseGameObject object;
  TakeEvent(this.object);
}

class DropEvent extends Event {
  BaseGameObject object;
  DropEvent(this.object);
}

class WearEvent extends Event {
  WearableGameObject object;
  WearEvent(this.object);
}

class RemoveEvent extends Event {
  WearableGameObject object;
  RemoveEvent(this.object);
}

class UseEvent extends Event {
  BaseGameObject object;
  UseEvent(this.object);
}