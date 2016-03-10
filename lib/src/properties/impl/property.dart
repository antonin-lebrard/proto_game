part of proto_game.properties;

class BaseProperty<T extends Object>{

  T value;

  String name;

  String description;

  BaseProperty(this.name, this.description, this.value);

}

class ModifiedProperty extends BaseProperty{

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