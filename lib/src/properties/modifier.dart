part of proto_game.properties;


abstract class Modifier {

  /// Could be called with more than one [BaseProperty]
  dynamic getModifiedValue(BaseProperty property, HasProperties context);

}

class NoModifier extends Modifier {

  dynamic getModifiedValue(BaseProperty property, HasProperties context) => property.getValue();

}

class CustomModifier extends Modifier {

  Map<BaseProperty, StoredOperation> modifiers = new Map();

  dynamic getModifiedValue(BaseProperty property, HasProperties context) {
    StoredOperation op = modifiers[property];
    if (op == null) return property;
    // copy it to not keep references to the base property we may modify again
    op = new StoredOperation.from(op, map:(element){
      if (element is BaseProperty || element is GlobalVariable){
        return new TempVariable(element.getValue());
      }
    });
    return op.applyOperation();
  }

}


