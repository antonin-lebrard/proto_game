part of proto_game.npc;


class Npc implements ExposedAPI, HasProperties, HasDescription, HasId {

  String name_id;

  String displayName;

  Map<String, BaseProperty> properties = new Map();

  List<BaseGameObject> inventory = new List();

  List<WearableGameObject> wearing = new List();

  List<NpcInteraction> interactions = new List();

  BaseProperty getProperty(String name) => properties[name];

  BaseProperty getFinalProperty(String name) {
    if (properties[name] == null) {
      Logger.log(new MessageError("Wrong name, property $name does not exist in npc $name_id"));
      return null;
    }
    return new ModifiedProperty(properties[name], wearing, this);
  }

  // TODO : proper description
  String getDescription() => "TODO : $name_id";

  String getId() => name_id;

  Map<String, dynamic> exposeAPI() {
    return {
      name_id : properties
    };
  }
}