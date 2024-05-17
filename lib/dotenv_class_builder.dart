import 'dart:async';
import 'dart:io';
import 'package:build/build.dart';

Builder envFileBuilder(BuilderOptions options) => EnvFileBuilder(options);

class EnvFileBuilder implements Builder {
  final BuilderOptions options;

  EnvFileBuilder(this.options);

  @override
  FutureOr<void> build(BuildStep buildStep) async {
    // Az outputId meghatározza, hogy hová fogunk generálni
    final outputBuffer = StringBuffer();
    Map<String, Map<String, String>> variables = {
      'Environment': {},
    };

      // Betöltjük a dotenv fájlokat
    for (String dotEnvPath in options.config["env_file_paths"]) {
        File dotEnvFile = File(dotEnvPath);
        List<String> lines = dotEnvFile.readAsLinesSync();

        String currentClass = 'Environment';

        for (String line in lines) {
          if (line.startsWith('//START_CLASS:')) {
            currentClass = line.split(':').last;
            currentClass = _convertToCamelCase(currentClass, isClassName: true);
            if (!variables.containsKey(currentClass)) {
              variables[currentClass] = {};
            }
          } else if (line.startsWith('//END_CLASS')) {
            currentClass = 'Environment';
          } else if (line.isNotEmpty && line.contains('=')) {
            List<String> parts = line.split('=');
            String key = parts[0];
            String value = parts[1];

            String camelCaseKey = _convertToCamelCase(key);

            variables[currentClass]?[camelCaseKey] = value;
          }
        }
      }

    variables.removeWhere((key, variable) => variable.isEmpty);

    outputBuffer.writeln("/// Please don't modify and remove this file.");
    outputBuffer.writeln("/// Run: \$ flutter pub run build_runner build --delete-conflicting-outputs");
    outputBuffer.writeln("library;\n");

    // Iterálunk a variables map-en
    variables.forEach((className, classVariables) {
      // Új osztály nevének definiálása
      outputBuffer.writeln('\nclass $className {');

      // Iterálunk az osztályhoz tartozó változókon
      classVariables.forEach((variableName, variableValue) {
        // Ellenőrizzük a változó típusát és megfelelően formázzuk
        if (variableValue.toLowerCase() == 'true' || variableValue.toLowerCase() == 'false') {
          // Bool type
          bool boolValue = variableValue.toLowerCase() == 'true';
          outputBuffer.writeln('  static const bool $variableName = $boolValue;');
        } else if (DateTime.tryParse(variableValue) != null) {
          // DateTime type
          DateTime dateTimeValue = DateTime.parse(variableValue);
          outputBuffer.writeln('  static final DateTime $variableName = DateTime(${dateTimeValue.year}, ${dateTimeValue.month}, ${dateTimeValue.day});');
        } else if (int.tryParse(variableValue) != null) {
          // Integer type
          int intValue = int.parse(variableValue);
          outputBuffer.writeln('  static const int $variableName = $intValue;');
        } else {
          // String type
          if ("'\"`".contains(variableValue[0]) && variableValue[0] == variableValue[variableValue.length - 1]) {
            String formatedValue = variableValue.substring(1, variableValue.length - 2);
            outputBuffer.writeln('  static const String $variableName = \'$formatedValue\';');
          } else {
            outputBuffer.writeln('  static const String $variableName = \'$variableValue\';');
          }
        }
      });

      // Osztály lezárása
      outputBuffer.writeln('}\n');
    });

    try {
      // Kiírjuk a generált kódot a fájlba
      File outputFile = File("lib/util/environments.g.dart");
      if (await outputFile.exists()) {
        await outputFile.delete(recursive: true);
      }

      await outputFile.create(recursive: true);
      outputFile.writeAsStringSync(outputBuffer.toString(), mode: FileMode.write);

      final outputId = AssetId(buildStep.inputId.package, outputFile.path);
      await buildStep.writeAsString(outputId, outputBuffer.toString());
    } catch (e, stackTrace) {
      print('$e \n$stackTrace');
    }
  }

  @override
  Map<String, List<String>> get buildExtensions => {
    ".env": [".g.dart"],
  };

  String _convertToCamelCase(String key, {bool isClassName = false}) {
    List<String> words = key.split(RegExp(r'[ _]'));
    String firstChar = words.first.toLowerCase();
    if (isClassName) {
      firstChar = firstChar[0].toUpperCase() + firstChar.substring(1);
    }
    String camelCase = firstChar + words.sublist(1).map((word) => word[0].toUpperCase() + word.substring(1).toLowerCase()).join('');
    return camelCase;
  }
}