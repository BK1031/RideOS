// ignore_for_file: avoid_print

class Logger {
  LogLevel _level = LogLevel.info;
  List<Log> logs = [];

  void setLevel(LogLevel level) {
    log("Setting log level to $level", LogLevel.debug);
    _level = level;
  }

  void log(var message, [LogLevel logLevel = LogLevel.info, Map<String, dynamic>? data]) {
    Log log = Log(message.toString(), logLevel);
    log.data = data;
    logs.add(log);
    if (logLevel.index >= _level.index) {
      print("${log.time.toLocal()} [${log.level.toString().split(".")[1].toUpperCase()}] ${log.message}");
      if (log.data != null) {
        print(log.data);
      }
    }
  }
}

class Log {
  DateTime time = DateTime.now().toUtc();
  String message = "";
  LogLevel level = LogLevel.info;
  Map<String, dynamic>? data;
  Log(this.message, this.level);
}

enum LogLevel {
  debug,
  info,
  warn,
  error
}