part of proto_game.npc;



class InteractionChoice {

  String id;

  List<Choice> choices = new List();

  InteractionChoice(this.id);

  Future execute() async {
    Choice c = await Game.game.gameLinkIo.presentChoices(choices);
    if (c != null) {
      Game.game.gameLinkIo.write(c.text);
      c.operations.forEach((StoredOperation o) => o.applyOperation());
    }
  }

}

class Choice {

  String name;

  Text text;

  List<StoredOperation> operations = new List();

  Choice(this.name, String text) {
    this.text = new Text.fromString(text);
  }

  Choice.cancel() {
    this.name = "Cancel";
  }

}
