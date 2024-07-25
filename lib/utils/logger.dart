// ignore_for_file: avoid_print

class Logger {
  LogLevel level = LogLevel.info;
  List<Log> logs = [];

  void log(var message, [LogLevel logLevel = LogLevel.info, Map<String, dynamic>? data]) {
    print(message.toString());
    logs.add(Log(message.toString(), logLevel));
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