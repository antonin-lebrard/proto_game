part of proto_game.properties;

abstract class BaseModifier{

  /**
   * Could be called with more than one [BaseProperty]
   */
  Object getModifiedValue(BaseProperty property);

}

abstract class HasModifier{

  BaseModifier getModifier();

}