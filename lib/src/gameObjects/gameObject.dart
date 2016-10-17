part of proto_game.gameObjects;

class BaseGameObject extends ExposedAPI implements HasDescription {

  String name_id;

  String displayName;

  String description;

  Map<String, BaseProperty> properties;

  Map<String, dynamic> exposeAPI() {
    return { name_id : properties };
  }

  BaseGameObject(this.name_id, this.displayName, this.description, this.properties);

  bool executeAction(String action){
    Function eventCreator = EventMappings.getEventCreatorFromName(action);
    if (eventCreator == null) {
      print("wrong action name, no event mapped on $action, or object not supporting $action");
      return false;
    }
    Event evt = eventCreator(this);
    if (new EventsManager().emitEvent(evt))
      return false;
    return _executeAction(evt);
  }

  bool _executeAction(Event event){
    if (event.runtimeType == ExamineEvent){
      Game.game.lowLevelIo.writeLine(this.description);
      return true;
    }
    else if (event.runtimeType == TakeEvent){
      Game.game.player.inventory.add(this);
      Game.game.player.plateau.currentRoom.objects.remove(this);
      Game.game.lowLevelIo.writeNewLine("You have taken $displayName");
    }
    else if (event.runtimeType == DropEvent){
      Game.game.player.plateau.currentRoom.objects.add(this);
      Game.game.player.inventory.remove(this);
      Game.game.lowLevelIo.writeNewLine("You have dropped $displayName");
    }
    return false;
  }

  toString() => name_id;

  String getDescription() => this.description;

}

class WearableGameObject extends BaseGameObject implements HasModifier {

  Modifier modifier;

  WearableGameObject(String name_id, String displayName, String description, Map<String, BaseProperty> properties, this.modifier) :
        super(name_id, displayName, description, properties) {}

  WearableGameObject.noModifier(String name_id, String displayName, String description, Map<String, BaseProperty> properties)
    : super(name_id, displayName, description, properties)
  {
    this.modifier = new NoModifier();
  }

  Modifier getModifier() => modifier;

  bool _executeAction(Event event){
    if (!super._executeAction(event)){
      if (event.runtimeType == WearEvent){
        Game.game.player.wearing.add(this);
        Game.game.player.inventory.remove(this);
        Game.game.player.plateau.currentRoom.objects.remove(this);
        Game.game.lowLevelIo.writeNewLine("You are now wearing $displayName on yourself");
      }
      else if (event.runtimeType == RemoveEvent){
        Game.game.player.inventory.add(this);
        Game.game.player.wearing.remove(this);
        Game.game.lowLevelIo.writeNewLine("You have removed $displayName from yourself");
      }
    }
    return false;
  }

}

class ConsumableGameObject extends BaseGameObject implements HasModifier {

  Modifier modifier;

  ConsumableGameObject(String name_id, String displayName, String description, Map<String, BaseProperty> properties, this.modifier)
    : super(name_id, displayName, description, properties)
  {

  }
  ConsumableGameObject.noModifier(String name_id, String displayName, String description, Map<String, BaseProperty> properties)
      : super(name_id, displayName, description, properties)
  {
    this.modifier = new NoModifier();
  }

  Modifier getModifier() => modifier;

  bool _executeAction(Event event){
    if (!super._executeAction(event)){
      if (event.runtimeType == UseEvent){
        // TODO : consumable doing something
      }
    }
    return false;
  }

}