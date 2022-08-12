
import 'package:flutter/cupertino.dart';

/// component定位器
/// 通过注解@Component自动化注册
/// 通过[useComponent]使用注册的组件
abstract class ComponentLocator {
  ReuseComponent useComponentByName({required String name, Object? params, OnReceipt? onReceipt});
}

/// 支持跨模块重用的widget应该混入这个类
/// 容器中 "xxx" : (Map param) => ReuseComponent(param);
abstract class ReuseComponent {

  Map? param;
  OnReceipt? onReceipt;

  /// 执行参数映射
  /// 将MAP转换成真正自定义组件需要的参数
  executeMap();

  /// 创建并返回真正的widget
  Widget widget();

  call(Map param) {
    executeMap();
    return widget();
  }
}

/// 解决回调的问题
/// 设置了多个"位置可选参数"，需要时可以使用
typedef OnReceipt = Function([Object? receipt, Object? o1, Object? o2, Object? o3, Object? o4, Object? o5,]);

/// 具体的实现类
class AA extends ReuseComponent {
  @override
  executeMap() {
    // TODO: implement executeMap
    throw UnimplementedError();
  }

  @override
  Widget widget() {
    onReceipt?.call(1, 2);
    // TODO: implement widget
    throw UnimplementedError();
  }

}



