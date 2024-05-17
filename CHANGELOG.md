# 0.1.2

* FIX: generate empty Environment or another classes
* FIX: include just in `lib` directory `.env` files
* FIX: missing `build_runner` package
* UPDATE: output to `lib/util/environments.g.dart`
* UPDATE: `README.md` (Usage)

# 0.1.1

* FIX: On use class_name another time or another file clear latest variables.
* FIX: On use many `.env` files write same classes many times.
* FIX: `build.yaml` file
* FIX: Clear `.env` files

# 0.1.0

* Convert .env files to `/lib/utils/environments.g.dart`
* Can handle String, int, bool, DateTime
* Can describe environment class name with //START_CLASS=<YOUR_CLASS_NAME> and with close //END_CLASS
* in `build.yaml` options > env_file_paths parameter can add env files paths
