import 'package:locator/locator.dart';
import 'package:locator/src/annotations/service/service.dart';
import 'package:locator/src/generators/track.dart';
import 'package:source_gen/source_gen.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';

/// Service注解对应的生成器
class ServiceGenerator extends GeneratorForAnnotation<Service> {
  final String tag = '🌎🌎🌎🌎';

  String className = '';
  String prefix = '';

  late BuildStep buildStep;

  @override
  generateForAnnotatedElement(
      Element element, ConstantReader annotation, BuildStep buildStep) {
    //print('$tag ${buildStep.inputId.uri} -- ${buildStep.inputId.hashCode}');
    this.buildStep = buildStep;

    /// 只有顶层节点（类、顶层函数等）才会被扫描
    /// 首先，被注解的应该是个类并且是可见类
    if (element.kind == ElementKind.CLASS && element.isPublic) {
      ClassElement classElement = element as ClassElement;
      className = element.name;
      prefix = annotation.peek('name')?.stringValue??className;
      try {
        _processClassElement(classElement);
      } catch (e) {
        rethrow;
      }
    }
  }


  _isParametersCompliant(ParameterElement element) {
    return element.type.isDartCoreString ||
        element.type.isDartCoreBool ||
        element.type.isDartCoreFunction ||
        element.type.isDartCoreList ||
        element.type.isDartCoreMap ||
        element.type.isDartCoreIterable ||
        element.type.isDartCoreSet ||
        element.type.isDartCoreInt ||
        element.type.isDartCoreDouble ||
        element.type.isDartCoreNum;
  }

  _processClassElement(ClassElement classElement) {

    /// 先处理本类的方法
    for (var element in classElement.methods) {
      for (var value in element.metadata) {
        String? annotation = value.computeConstantValue()?.type.toString();
        if (annotation == 'Action') {
          track.addImports(buildStep);
          track.actions.addAll(_createKVPairForMethods(element, 0));
        }
        if (annotation == 'Component') {
          track.addImports(buildStep);
          track.components.addAll(_createKVPairForMethods(element, 1));
        }
      }
    }
    /// 本类的Getter
    for (var element in classElement.accessors) {
      if(element.isGetter) {
        for (var value in element.metadata) {
          String? annotation = value.computeConstantValue()?.type.toString();
          if (annotation == 'Action') {
            track.addImports(buildStep);
            track.actions.addAll(_createKVPairForGetter(element, 0));
          }
          if (annotation == 'Component') {
            track.addImports(buildStep);
            track.components.addAll(_createKVPairForGetter(element, 1));
          }
        }
      }
    }

    /// mixin 中的数据
    for (var mixin in classElement.mixins) {
      for (var element in mixin.methods) {
        for (var value in element.metadata) {
          String? annotation = value.computeConstantValue()?.type.toString();
          if (annotation == 'Action') {
            track.addImports(buildStep);
            track.actions.addAll(_createKVPairForMethods(element, 0));
          }
          if (annotation == 'Component') {
            track.addImports(buildStep);
            track.components.addAll(_createKVPairForMethods(element, 1));
          }
        }
      }
    }

    for (var mixin in classElement.mixins) {
      for (var element in mixin.accessors) {
        if(element.isGetter) {
          for (var value in element.metadata) {
            String? annotation = value.computeConstantValue()?.type.toString();
            if (annotation == 'Action') {
              track.addImports(buildStep);
              track.actions.addAll(_createKVPairForGetter(element, 0));
            }
            if (annotation == 'Component') {
              track.addImports(buildStep);
              track.components.addAll(_createKVPairForGetter(element, 1));
            }
          }
        }
      }
    }

  }

  _createKVPairForMethods(MethodElement element, int type) {
    String str = '';

    /// 方法的参数必须是基本数据类型
    if (!element.parameters.every((param) => _isParametersCompliant(param))) {
      throw Exception(
          '❗❗❗此方法的参数必须是Dart的基本数据类型，不支持自定义的类($className::${element.name})');
    }

    str = '(';
    for (ParameterElement param in element.parameters) {
      if (param.isNamed) {
        str += '${param.name}: params["${param.name}"], ';
      } else {
        str += 'params["${param.name}"], ';
      }
    }
    if (element.parameters.isNotEmpty) {
      str = str.replaceRange(str.length - 2, str.length, '');
    }
    str += ')';

    String? name = type == 0 ? element.getActionName() : element.getComponentsName();
    String key = '$prefix/${name??element.name}';
    String value =
        '(Map<String, dynamic> params) => t${buildStep.inputId.hashCode}.$className().${element.name}$str';

    if (track.actions.containsKey(key)) {
      throw Exception("""❗❗❗
        重复的Action 路径
        当前扫描位置: ${buildStep.inputId.uri}
        Class: $className
        Method: ${element.name}
        """);
    }

    return {key: value};
  }

  _createKVPairForGetter(PropertyAccessorElement element, int type) {
    String? name = type == 0 ? element.getActionName() : element.getComponentsName();
    String key = '$prefix/${name??element.name}';
    String value =
        '() => t${buildStep.inputId.hashCode}.$className().${element.name}';

    if (track.actions.containsKey(key)) {
      throw Exception("""❗❗❗
        重复的Action 路径
        当前扫描位置: ${buildStep.inputId.uri}
        Class: $className
        Method: ${element.name}
        """);
    }

    return {key: value};
  }
}

extension on MethodElement {

  getActionName() {
    var annotation = metadata.where((element) => element.computeConstantValue()?.type.toString() == 'Action').first;
    String? str = annotation.computeConstantValue()?.getField('name')?.toStringValue();
    return str;
  }

  getComponentsName() {
    var annotation = metadata.where((element) => element.computeConstantValue()?.type.toString() == 'Component').first;
    String? str = annotation.computeConstantValue()?.getField('name')?.toStringValue();
    return str;
  }

}

extension on PropertyAccessorElement {

  getActionName() {
    var annotation = metadata.where((element) => element.computeConstantValue()?.type.toString() == 'Action').first;
    String? str = annotation.computeConstantValue()?.getField('name')?.toStringValue();
    return str;
  }

  getComponentsName() {
    var annotation = metadata.where((element) => element.computeConstantValue()?.type.toString() == 'Component').first;
    String? str = annotation.computeConstantValue()?.getField('name')?.toStringValue();
    return str;
  }

}