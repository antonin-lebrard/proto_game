part of proto_game.npc;


class NpcInteraction {

  String actionName;

  List<StoredCondition> conditions = new List();
  List<StoredOperation> operations = new List();

  bool anyConditions;

  Text text;

  NpcInteraction(this.actionName, {bool anyConditions: false, String text: ""}){
    this.anyConditions = anyConditions;
    this.text = new Text.fromString(text);
  }

}