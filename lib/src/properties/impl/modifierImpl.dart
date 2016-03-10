part of proto_game.properties;

class NoModifier extends BaseModifier {

  Object getModifiedValue(BaseProperty property) => property.value;

}