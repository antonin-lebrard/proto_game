part of proto_game.gameObjects;

class BaseGameObject extends HasDescription {

  num id;

  String name;

  String description;

  Map<String, BaseProperty> properties;

  BaseGameObject(this.id, this.name, this.description, this.properties);

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
      Game.game.lowLevelIo.writeNewLine("You have taken $name");
    }
    else if (event.runtimeType == DropEvent){
      Game.game.player.plateau.currentRoom.objects.add(this);
      Game.game.player.inventory.remove(this);
      Game.game.lowLevelIo.writeNewLine("You have dropped $name");
    }
    return false;
  }

  toString() => name;

  String getDescription() => this.description;

}

class WearableGameObject extends BaseGameObject implements HasModifier {

  BaseModifier modifier;

  WearableGameObject(num id, String name, String description, Map<String, BaseProperty> properties, this.modifier) :
        super(id, name, description, properties) {}

  WearableGameObject.noModifier(num id, String name, String description, Map<String, BaseProperty> properties)
    : super(id, name, description, properties)
  {
    this.modifier = new NoModifier();
  }

  BaseModifier getModifier() => modifier;

  bool _executeAction(Event event){
    if (!super._executeAction(event)){
      if (event.runtimeType == WearEvent){
        Game.game.player.wearing.add(this);
        Game.game.player.inventory.remove(this);
        Game.game.player.plateau.currentRoom.objects.remove(this);
        Game.game.lowLevelIo.writeNewLine("You are now wearing $name on yourself");
      }
      else if (event.runtimeType == RemoveEvent){
        Game.game.player.inventory.add(this);
        Game.game.player.wearing.remove(this);
        Game.game.lowLevelIo.writeNewLine("You have removed $name from yourself");
      }
    }
    return false;
  }

}

class ConsumableGameObject extends BaseGameObject implements HasModifier {

  BaseModifier modifier;

  ConsumableGameObject(num id, String name, String description, Map<String, BaseProperty> properties, this.modifier)
    : super(id, name, description, properties)
  {

  }
  ConsumableGameObject.noModifier(num id, String name, String description, Map<String, BaseProperty> properties)
      : super(id, name, description, properties)
  {
    this.modifier = new NoModifier();
  }

  BaseModifier getModifier() => modifier;

  bool _executeAction(Event event){
    if (!super._executeAction(event)){
      if (event.runtimeType == UseEvent){
        // TODO : consumable doing something
      }
    }
    return false;
  }

}