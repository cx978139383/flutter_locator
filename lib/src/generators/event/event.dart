import 'package:locator/locator.dart';
import 'package:locator/src/generators/track.dart';
import 'package:source_gen/source_gen.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';

/// Locator注解对应的生成器
class EventGenerator extends GeneratorForAnnotation<Event> {
  @override
  generateForAnnotatedElement(
      Element element, ConstantReader annotation, BuildStep buildStep) async {
    /// 只有顶层节点（类、顶层函数等）才会被扫描
    /// 首先，被注解的应该是个类并且是可见类
    if (element.kind == ElementKind.CLASS && element.isPublic) {
      ClassElement classElement = element as ClassElement;
      String key = annotation.peek('name')?.stringValue??classElement.name;
      String value = '(dynamic bus) => bus.on<t${buildStep.inputId.hashCode}.${classElement.name}>()';
      if (track.events.containsKey(key)) throw Exception('重复');
      track.addImports(buildStep);
      track.events[key] = value;
    }
  }

}
