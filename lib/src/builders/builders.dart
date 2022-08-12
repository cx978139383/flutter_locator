import 'package:locator/src/generators/event/event.dart';
import 'package:locator/src/generators/locator/locator.dart';
import 'package:locator/src/generators/service/service.dart';
import 'package:source_gen/source_gen.dart';
import 'package:build/build.dart';


Builder builderForService(BuilderOptions options) => LibraryBuilder(ServiceGenerator(), generatedExtension: '.service.registry.dart');

Builder builderForLocator(BuilderOptions options) => LibraryBuilder(LocatorGenerator(), generatedExtension: '.registry.dart');

Builder builderForEvent(BuilderOptions options) => LibraryBuilder(EventGenerator(), generatedExtension: '.event.registry.dart');