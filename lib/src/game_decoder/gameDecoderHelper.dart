part of proto_game.gameDecoder;


class GameDecoderHelper {

  static List toListSupportingMap(var content){
    if (content == null) return new List();
    if (content is Map) content = new List()..add(content);
    if (content is List) return content;
    else {
      Logger.log(new DecodingError(content, "wrongly formatted, awaiting List or Map"));
      return new List();
    }
  }

  static List toListSupportingString(var content){
    if (content == null) return new List();
    if (content is String) content = new List()..add(content);
    if (content is List) return content;
    else {
      Logger.log(new DecodingError(content, "wrongly formatted, awaiting List or String"));
      return new List();
    }
  }

  static String toStringSupportingList(var content){
    if (content == null) return "";
    if (content is List<String>) content = content.join("");
    if (content is String) return content;
    else {
      Logger.log(new DecodingError(content, "wrongly formatted, awaiting String or List"));
      return "";
    }
  }

  static bool isMandatoryKeyPresent(Map content, String key){
    if (content[key] == null){
      Logger.log(new DecodingError(content.toString(), "$key not specified, will not be parsed"));
      return false;
    }
    return true;
  }

  static bool isMandatoryKeysPresent(Map content, List<String> keys){
    bool allPresent = true;
    for (String key in keys)
      if (!isMandatoryKeyPresent(content, key))
        allPresent = false;
    return allPresent;
  }

}


