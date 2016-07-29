part of proto_game.properties;

abstract class BaseProperty<T> extends HasValue<T> {

  String name;

  String description;

  BaseProperty(this.name, this.description, T value) : super(value);

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
    : super(base.name, base.description, base.getValue())
  {
    if (modifierContainers != null) {
      modifierContainers.forEach((HasModifier modifierContainer) {
        if (modifierContainer.getModifier().getModifiedValue(this) == null) {
          print("Something wrong happened with property modifier : " + modifierContainer.getModifier().toString());
          return;
        }
        super.applyValue(modifierContainer.getModifier().getModifiedValue(this));
      });
    }
  }

  @override
  void applyValue(other){
    print("Warning : not supposed to change value of ModifiedProperty, do nothing");
  }

}