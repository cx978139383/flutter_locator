import 'package:locator/locator.dart';
import 'package:locator/src/generators/track.dart';
import 'package:source_gen/source_gen.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';

/// Locator注解对应的生成器
class LocatorGenerator extends GeneratorForAnnotation<Locator> {
  @override
  generateForAnnotatedElement(
      Element element, ConstantReader annotation, BuildStep buildStep) async {
    /// 只有顶层节点（类、顶层函数等）才会被扫描
    /// 首先，被注解的应该是个类并且是可见类
    if (element.kind == ElementKind.CLASS && element.isPublic) {
      //ClassElement classElement = element as ClassElement;
      String ignore = '// ignore_for_file: implementation_imports';
      return "$ignore\n${track.resForImports}\n\n${createActionRegistry()}\n\n${createComponentRegistry()}\n\n${createEventRegistry()}";
    }
  }

  String createActionRegistry() {
    if (track.actions.isEmpty) return "Map<String, Function> actions = {};";
    String str = '';
    for (var key in track.actions.keys) {
      str += "'$key' : ${track.actions[key]},\n";
    }
    str = str.replaceRange(str.length - 2, str.length, '');
    return "Map<String, Function> actions = {\n$str\n};";
  }

  String createComponentRegistry() {
    if (track.components.isEmpty) return "Map<String, Function> components = {};";
    String str = '';
    for (var key in track.components.keys) {
      str += "'$key' : ${track.components[key]},\n";
    }
    str = str.replaceRange(str.length - 2, str.length, '');
    return "Map<String, Function> components = {\n$str\n};";
  }

  String createEventRegistry() {
    if (track.events.isEmpty) return "Map<String, Function> events = {};";
    String str = '';
    for (var key in track.events.keys) {
      str += "'$key' : ${track.events[key]},\n";
    }
    str = str.replaceRange(str.length - 2, str.length, '');
    return "Map<String, Function> events = {\n$str\n};";
  }
}
