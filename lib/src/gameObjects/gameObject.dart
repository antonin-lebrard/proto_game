part of proto_game.gameObjects;

class BaseGameObject{

  num id;

  String name;

  String description;

  BaseGameObject(this.id, this.name, this.description);

  toString() => name;

}

class WearableGameObject extends BaseGameObject implements HasModifier {

  BaseModifier modifier;

  WearableGameObject(num id, String name, String description, this.modifier) : super(id, name, description) {}

  WearableGameObject.noModifier(num id, String name, String description)
    : super(id, name, description)
  {
    this.modifier = new NoModifier();
  }

  BaseModifier getModifier() => modifier;

}

class ConsumableGameObject extends BaseGameObject implements HasModifier {

  BaseModifier modifier;

  ConsumableGameObject(num id, String name, String description, this.modifier)
    : super(id, name, description)
  {

  }
  ConsumableGameObject.noModifier(num id, String name, String description)
      : super(id, name, description)
  {
    this.modifier = new NoModifier();
  }

  BaseModifier getModifier() => modifier;

}