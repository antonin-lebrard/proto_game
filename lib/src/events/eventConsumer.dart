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
    EventMappings.eventMappings.forEach((Type key, Map value){
      if (value['name'] == listenTo){
        this.listenTo = key;
        return;
      }
    });
  }

  bool consume(Event event){
    // TODO
  }

}