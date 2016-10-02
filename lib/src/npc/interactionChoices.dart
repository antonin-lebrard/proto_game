part of proto_game.npc;



class InteractionChoice {

  String id;

  List<Choice> choices = new List();

  InteractionChoice(this.id);

}

class Choice {

  String name;

  String text;

  List<StoredOperation> operations = new List();

  Choice(this.name, this.text);

  Choice.cancel() {
    this.name = "Cancel";
  }

}
