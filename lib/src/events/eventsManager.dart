part of proto_game.events;


class EventsManager {

  static Map<Type, String> _eventsClassToName = {
    MoveEvent   : "move",
    TakeEvent   : "take",
    DropEvent   : "drop",
    WearEvent   : "wear",
    RemoveEvent : "remove",
    UseEvent    : "use",
  };

  static EventsManager _singleton;

  Map<Type, List<EventConsumer>> _consumers = new Map();

  factory EventsManager(){
    if (_singleton == null)
      _singleton = new EventsManager._internal();
    return _singleton;
  }

  EventsManager._internal(){
    for (Type t in _eventsClassToName.keys){
      _consumers[t] = new List();
    }
  }

  bool emitEvent(Event event){
    List<EventConsumer> consumers = _consumers[event.runtimeType];
    if (consumers == null || consumers.length == 0)
      return true;
    for (EventConsumer consumer in consumers){
      if (consumer.consume(event)){
        return true;
      }
    }
    return false;
  }

  void addEventListener(Type eventType, EventConsumer consumer){
    if (_eventsClassToName.keys.contains(eventType)) {
      _consumers[eventType].add(consumer);
    } else {
      print("Warning : eventType does not exist");
    }
  }

}