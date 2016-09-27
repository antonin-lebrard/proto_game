part of proto_game.events;


class EventMappings {

  static final Map<Type, Map<String, dynamic>> eventMappings = {
    MoveEvent : {
      "params": { "from": Room, "to": Room },
      "name": "move",
      "createInstance": (Room from, Room to) => new MoveEvent(from, to),
    },
    InteractEvent : {
      "params": { "npc": Npc, "action": String },
      "name": "interact",
      "createInstance": (Npc npc, String actionName) => new InteractEvent(npc, actionName),
    },
    ExamineEvent : {
      "params": { "thing": HasDescription },
      "name": "examine",
      "createInstance": (HasDescription thing) => new ExamineEvent(thing),
    },
    TakeEvent : {
      "params": { "object": BaseGameObject },
      "name": "take",
      "createInstance": (BaseGameObject object) => new TakeEvent(object),
    },
    DropEvent : {
      "params": { "object": BaseGameObject },
      "name": "drop",
      "createInstance": (BaseGameObject object) => new DropEvent(object),
    },
    WearEvent : {
      "params": { "object": WearableGameObject },
      "name": "wear",
      "createInstance": (WearableGameObject object) => new WearEvent(object),
    },
    RemoveEvent : {
      "params": { "object": WearableGameObject },
      "name": "remove",
      "createInstance": (WearableGameObject object) => new RemoveEvent(object),
    },
    UseEvent : {
      "params": { "object": BaseGameObject },
      "name": "use",
      "createInstance": (BaseGameObject object) => new UseEvent(object),
    },
  };

  static Function getEventCreatorFromName(String name){
    Function eventCreator = null;
    EventMappings.eventMappings.forEach((_, Map<String, dynamic> value){
      if (value["name"] == name){
        eventCreator = value["createInstance"];
      }
    });
    return eventCreator;
  }

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

class InteractEvent extends Event {
  Npc npc;
  String actionName;
  InteractEvent(this.npc, this.actionName){
    _setProperties({"npc":npc, "action":actionName});
  }
}

class ExamineEvent extends Event {
  HasDescription thing;
  ExamineEvent(this.thing) {
    _setProperties({"thing":thing});
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