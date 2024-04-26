struct Logger:
    var _min_level: UInt8 # Changing to Int here and for log "level" argument makes it work
    var counter: Int

    fn __init__(inout self):
        self._min_level = 0
        self.counter = 0

    fn mutated_test(inout self) -> Bool:
        self.counter += 1
        return True

    fn log(inout self, level: UInt8, message: String):
        # adding any of the following line makes it work

        # print(""+str(2))

        # var s = ""+str(2)
        
        # if self.mutated_test() and self._min_level == 0:
        #     self.counter += 1
        #     print(message)
        #     return

        if self.mutated_test() and level >= self._min_level:
            self.counter += 1
            print(message)
        # else:
        #     print(""+str(2))

    fn debug(inout self, message: String):
        self.log(0, message)

fn out_debug(inout logger: Logger):
    logger.debug("Calling debug from outside crashes everything")

fn main():
    var logger = Logger()
    print(logger.counter)
    
    logger.log(0, "Calling log directly works fine")
    print(logger.counter)
    logger.debug("Calling debug should work but doesnt")
    print(logger.counter)

    # Calling out_debug makes previous working calls fail too
    # out_debug(logger)