class CoreLocator {
  static final CoreLocator _instance = CoreLocator._();

  CoreLocator._();

  factory CoreLocator() {
    return _instance;
  }

  /// 将注册表初始化进来
  initialize({Map<String, dynamic>? actions, Map<String, dynamic>? components, Map<String, dynamic>? events}) {
    _interpreter = LocatorProtocolInterpreter(
        actions: actions ?? {},
        components: components ?? {},
        events: events ?? {});
  }

  LocatorProtocolInterpreter? _interpreter;

  // request(LocatorRequest request) {
  //   assert(_interpreter != null, 'Locator注册表未初始化，请调用Locator().initialize()方法');
  //   return _interpreter?._parseRequest(request);
  // }

  action({required String url, Map<String, dynamic>? params}) {
    return _interpreter?._parseRequest(LocatorRequest(
        type: LocatorRequestType.action, url: url, params: params));
  }

  component({required String url, Map<String, dynamic>? params}) {
    return _interpreter?._parseRequest(LocatorRequest(
        type: LocatorRequestType.component, url: url, params: params));
  }

  Stream subscribe({required String url, required eventBus}) {
    return _interpreter?._parseEvent(url, eventBus);
  }
}

enum LocatorRequestType { action, component, event }

class LocatorRequest {
  final LocatorRequestType type;
  final String url;
  final Map<String, dynamic>? params;
  final Function(dynamic value)? closure;

  LocatorRequest(
      {required this.type, required this.url, this.params, this.closure});
}

/// 通信协议解释器
class LocatorProtocolInterpreter {
  final Map<String, dynamic> actions;
  final Map<String, dynamic> components;
  final Map<String, dynamic> events;

  LocatorProtocolInterpreter(
      {required this.actions, required this.components, required this.events});

  _parseRequest(LocatorRequest request) {
    switch (request.type) {
      case LocatorRequestType.action:
        return _ActionParser(source: actions).parseRequest(request);
      case LocatorRequestType.component:
        return _ComponentParser(source: components).parseRequest(request);
      case LocatorRequestType.event:
        return _EventParser(source: events).parseRequest(request);
    }
  }

  _parseEvent(String url, dynamic eventBus) {
    return events[url].call(eventBus);
  }
}

abstract class _Parser {
  LocatorRequestType get type;

  parseRequest(LocatorRequest request);
}

class _ActionParser extends _Parser {
  late Map<String, dynamic> source;

  _ActionParser({Map<String, dynamic>? source}) : source = source ?? {};

  @override
  LocatorRequestType get type => LocatorRequestType.action;

  @override
  parseRequest(LocatorRequest request) {
    return source[request.url].call(request.params ?? <String, dynamic>{});
  }
}

class _ComponentParser extends _Parser {
  late Map<String, dynamic> source;

  _ComponentParser({Map<String, dynamic>? source}) : source = source ?? {};

  @override
  LocatorRequestType get type => LocatorRequestType.action;

  @override
  parseRequest(LocatorRequest request) {
    return source[request.url].call(request.params ?? <String, dynamic>{});
  }
}

class _EventParser extends _Parser {
  late Map<String, dynamic> source;

  _EventParser({Map<String, dynamic>? source}) : source = source ?? {};

  @override
  LocatorRequestType get type => LocatorRequestType.action;

  @override
  parseRequest(LocatorRequest request) {
    return source[request.url].call(request.params ?? <String, dynamic>{});
  }
}
