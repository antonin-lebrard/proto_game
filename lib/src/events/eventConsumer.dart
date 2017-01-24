part of proto_game.events;

abstract class EventConsumer {

  Type listenTo;

  bool stopEvent;

  EventConsumer();

  bool consume(Event event);

}

class CustomizableEventConsumer extends EventConsumer {

  List<StoredCondition> conditions = new List();
  List<StoredOperation> operations = new List();

  bool anyConditions;

  Text text;

  CustomizableEventConsumer(String listenTo, {bool stopEvent:false, bool anyConditions:false}){
    for (Type key in EventMappings.eventMappings.keys){
      if (EventMappings.eventMappings[key]['name'] == listenTo){
        this.listenTo = key;
        break;
      }
    }
    if (listenTo == null)
      Logger.log(new DecodingError(listenTo, "Type of event specified in 'listenTo' field does not exists, will lead to numerous errors"));
    this.stopEvent = stopEvent;
    this.anyConditions = anyConditions;
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
      Game.game.gameLinkIo.write(text, event);
      return stopEvent;
    }
    return false;
  }

}