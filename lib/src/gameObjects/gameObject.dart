part of proto_game.gameObjects;

class BaseGameObject {

  num id;

  String name;

  String description;

  Map<String, BaseProperty> properties;

  BaseGameObject(this.id, this.name, this.description, this.properties);

  bool executeAction(String action, Player player){
    return false;
  }

  toString() => name;

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

}