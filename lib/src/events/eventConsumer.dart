part of proto_game.events;

abstract class EventConsumer {

  Type listenTo;

  EventConsumer();

  bool consume(Event event);

}

class CustomizableEventConsumer<E extends Event> extends EventConsumer {

  List<StoredCondition> conditions = new List();
  List<StoredOperation> operations = new List();

  CustomizableEventConsumer(String listenTo){
    for (Type key in EventMappings.eventMappings.keys){
      if (EventMappings.eventMappings[key]['name'] == listenTo){
        this.listenTo = key;
        return;
      }
    }
  }

  bool consume(Event event){
    if (conditions.every((StoredCondition condition) => condition.isConditionTrue(event))) {
      for (StoredOperation o in operations) {
        o.applyOperation();
      }
      return true;
    }
    return false;
  }

}