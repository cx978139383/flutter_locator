
import 'package:build/build.dart';

Track track = Track();

class Track {

  List<String> imports = [];
  List<String> importsOriginal = [];
  Map<String, String> actions = {};
  Map<String, String> components = {};
  Map<String, String> events = {};


  /// -------------------- import 部分 -------------------------
  String? get resForImports {
    String str = "";
    for (var element in imports) {
      str += element;
      str += '\n';
    }
    return str;
  }

  addImports(BuildStep buildStep) {
    String import = "import '${buildStep.inputId.uri}'";
    if (importsOriginal.contains(import)) return;
    importsOriginal.add(import);
    import += " as t${buildStep.inputId.hashCode};";
    imports.add(import);
  }


}