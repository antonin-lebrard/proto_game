part of proto_game.properties;

abstract class BaseProperty<T extends Object>{

  T value;

  String name;

  String description;

  BaseProperty(this.name, this.description, this.value);

}

class StringProperty extends BaseProperty<String> {
  StringProperty(String name, String description, String value) : super(name, description, value);
}
class NumProperty extends BaseProperty<num>{
  NumProperty(String name, String description, num value) : super(name, description, value);
}
class BoolProperty extends BaseProperty<bool>{
  BoolProperty(String name, String description, bool value) : super(name, description, value);
}

class ModifiedProperty extends BaseProperty {

  ModifiedProperty(BaseProperty base, List<HasModifier> modifierContainers)
    : super(base.name, base.description, base.value)
  {
    if (modifierContainers != null) {
      modifierContainers.forEach((HasModifier modifierContainer) {
        if (modifierContainer.getModifier().getModifiedValue(value) == null) {
          print("Something wrong happened with property modifier : " + modifierContainer.getModifier().toString());
          return;
        }
        this.value = modifierContainer.getModifier().getModifiedValue(value);
      });
    }
  }

}