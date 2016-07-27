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

  Map<String, List<EventConsumer>> _consumers = new Map();

  factory EventsManager(){
    if (_singleton == null)
      _singleton = new EventsManager();
    return _singleton;
  }

  EventsManager._internal(){
    for (String s in _eventsClassToName.values){
      _consumers[s] = new List();
    }
  }

  bool emitEvent(Event event){
    List<EventConsumer> consumers = _consumers[_eventsClassToName[event.runtimeType]];
    if (consumers == null || consumers.length == 0)
      return true;
    for (EventConsumer consumer in consumers){
      if (consumer.consume(event)){
        return true;
      }
    }
    return false;
  }

  void addEventListener(String eventType, EventConsumer consumer){
    if (_eventsClassToName.values.contains(eventType)) {
      _consumers[eventType].add(consumer);
    } else {
      print("Warning : eventType does not exist");
    }
  }

}