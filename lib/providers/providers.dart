import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

class LocatorProviderWidget extends StatelessWidget {

  final List<SingleChildWidget> providers;
  final Widget child;

  const LocatorProviderWidget({Key? key, required this.providers, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return providers.isEmpty ? child : MultiProvider(providers: providers, child: child,);
  }
}

class LocatorProviderManager {

  List<SingleChildWidget> providers = [];

  addAll(List<SingleChildWidget> providers) {
    providers = providers..addAll(providers)..toSet().toList();
  }

  removeAll() {
    providers = [];
  }

  add(SingleChildWidget provider) {
    providers = providers..add(provider)..toSet().toList();
  }

}

abstract class LocatorProvidersContributor {
  List<SingleChildWidget> get providers;
}