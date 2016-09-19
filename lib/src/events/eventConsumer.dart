part of proto_game.events;

abstract class EventConsumer {

  Type listenTo;

  EventConsumer();

  bool consume(Event event);

}

class CustomizableEventConsumer<E extends Event> extends EventConsumer {

  List<StoredCondition> conditions = new List();
  List<StoredOperation> operations = new List();

  bool stopEvent;
  bool anyConditions;

  String text;

  CustomizableEventConsumer(String listenTo, {String text:"", bool stopEvent:false, bool anyConditions:false}){
    for (Type key in EventMappings.eventMappings.keys){
      if (EventMappings.eventMappings[key]['name'] == listenTo){
        this.listenTo = key;
        break;
      }
    }
    this.stopEvent = stopEvent;
    this.anyConditions = anyConditions;
    this.text = text;
  }

  bool consume(Event event){
    bool conditionsMatched;
    if (anyConditions)
      conditionsMatched = conditions.any((StoredCondition condition) => condition.isConditionTrue(event));
    else
      conditionsMatched = conditions.every((StoredCondition condition) => condition.isConditionTrue(event));
    if (conditionsMatched) {
      for (StoredOperation o in operations) {
        o.applyOperation();
      }
      Game.game.lowLevelIo.writeLine(text);
      return stopEvent;
    }
    return false;
  }

}