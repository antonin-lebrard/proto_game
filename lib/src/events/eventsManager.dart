part of proto_game.events;


class EventsManager {

  static EventsManager _singleton;

  Map<Type, List<EventConsumer>> _consumers = new Map();

  factory EventsManager(){
    if (_singleton == null)
      _singleton = new EventsManager._internal();
    return _singleton;
  }

  EventsManager._internal(){
    for (Type t in EventMappings.eventMappings.keys){
      _consumers[t] = new List();
    }
  }

  Iterable<EventConsumer> get consumers => _consumers.values.fold(_consumers.values.first.toList(), (List<EventConsumer> v, List next) => v..addAll(next));

  bool emitEvent(Event event){
    List<EventConsumer> consumers = _consumers[event.runtimeType];
    if (consumers == null || consumers.length == 0)
      return false;
    List<EventConsumer> stoppingConsumers = consumers.where((EventConsumer e) => e.stopEvent).toList();
    List<EventConsumer> nonStoppingConsumers = consumers.where((EventConsumer e) => !e.stopEvent).toList();
    for (EventConsumer consumer in stoppingConsumers){
      if (consumer.consume(event)){
        return true;
      }
    }
    for (EventConsumer consumer in nonStoppingConsumers){
      if (consumer.consume(event)){
        return true;
      }
    }
    return false;
  }

  void addEventListener(Type eventType, EventConsumer consumer){
    if (_consumers.containsKey(eventType)) {
      _consumers[eventType].add(consumer);
    } else {
      Logger.log(new RuntimeError(eventType, "Warning : eventType does not exist"));
    }
  }

}