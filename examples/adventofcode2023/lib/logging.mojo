
alias LogLevel = Int

struct Logger:
    alias DEBUG = 0
    alias INFO = 1
    alias WARN = 2
    alias ERROR = 3
    alias CRITICAL = 4
    var _min_level: LogLevel

    fn __init__(inout self, level: LogLevel = Logger.INFO):
        self._min_level = level

    fn log(self, level: LogLevel, message: String):
        if level >= self._min_level:
            print(message)

    fn set_level(inout self, level: LogLevel):
        self._min_level = level
    
    fn get_level(self) -> LogLevel:
        return self._min_level

    fn debug(self, message: String):
        self.log(Logger.DEBUG, message)

    fn info(self, message: String):
        self.log(Logger.INFO, message)

    fn warn(self, message: String):
        self.log(Logger.WARN, message)

    fn error(self, message: String):
        self.log(Logger.ERROR, message)

    fn critical(self, message: String):
        self.log(Logger.CRITICAL, message)

    @staticmethod
    fn get(level: LogLevel = Logger.INFO) -> Logger:
        #TODO: make this a singleton when mojo supports top-level code, variables or struct static attributes
        return Logger(level)