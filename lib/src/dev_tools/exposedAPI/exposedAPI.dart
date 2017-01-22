library proto_game.exposedAPI;

import 'package:proto_game/src/dev_tools/logger/logger.dart';

abstract class ExposedAPI {

  Map<String, dynamic> exposeAPI();

  static dynamic getVarFromPath(Map<String, dynamic> startingPointAPI, List<String> path){
    var toReturn = startingPointAPI;
    for (int i = 0; i < path.length; i++){
      toReturn = startingPointAPI[path[i]];
      if (i != path.length - 1 && !(toReturn is Map)){
        throw new ExposedAPIBrowsingException(path, path[i]);
      }
    }
    return toReturn;
  }

}