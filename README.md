# dotenv_class_builder

A Flutter package for generating a Dart class from .env variables.


## Usage

Write `build.yaml` file like this in the project root:

```yaml
# build.yaml

builders:
  dotenv_class_builder:
    import: "package:dotenv_class_builder/dotenv_class_builder.dart"
    builder_factories: ["envFileBuilder"]
    auto_apply: dependents
    build_to: source
    build_extensions:
      ".env": ["lib/util/environments.g.dart"]

targets:
  $default:
    builders:
      dotenv_class_builder:
        enabled: true
        generate_for:
          include:
            - /**.env
        options:
          env_file_paths:
            - lib/<MY_MAGIC_ENV_FILENAME>.env
          sources:
            include: ["lib/**"]
```

Then run in your terminal:

 ```bash
 $ flutter run build_runner build --delete-conflicting-outputs
 ```