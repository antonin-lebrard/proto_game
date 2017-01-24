part of proto_game.text;


class Text {

  List<dynamic> whole = new List();

  Type eventType;

  Text.fromString(String text, [this.eventType]){
    TextDecodingHelper.decompose(text, _decodeGameVariable, _addPart, this.eventType);
  }

  HasValue _decodeGameVariable(String s){
    List<String> varParts = s.split('.');

    if (varParts[0] == "param"){
      HasValue o = DecodingHelper.decodeExpectedEventVariable(varParts, eventType);
      if (o != null) return o;
      else Logger.log(new MessageError("eventType is null, this error is tied to an error in the field 'listenTo' in an event consumer"));
    }
    else {
      HasValue o = DecodingHelper.decodeGameAPIVariable(varParts);
      if (o != null) return o;
    }
    return null;
  }

  _addPart(var part){
    if (part is ElseText){
      if (!whole.any((var line) => line is IfText)){
        throw new NoIfBeforeElseException();
      }
    }
    whole.add(part);
  }

  String getWholeText([Event event]){
    String wholeText = "";
    bool lastIfResult;
    for (var element in whole) {
      if (element is String)
        wholeText += element;
      else if (element is HasValue){
        if (element is ExpectedEventVariable)
          element.resolveVariable(event);
        wholeText += "${element.getValue()}";
        if (element is ExpectedEventVariable)
          element.resetVariable();
      }
      else if (element is IfText) {
        lastIfResult = element.condition.isConditionTrue(null);
        if (lastIfResult)
          wholeText += element.text.getWholeText();
      }
      else if (element is ElseText) {
        if (!lastIfResult) {
          wholeText += element.text.getWholeText();
          lastIfResult = null;
        }
      }
      else {
        wholeText += "$element";
      }
    }
    return wholeText;
  }

}