
fn greet[name: StringLiteral]():
    print("Hello, " + name + "!")

fn greet[name: String]():
    print("Hello, " + name + "!")

fn greet[name: StringLiteral, repeat: Int = 1]():
    for i in range(repeat):
        print("Hello, " + name + "!")

@value
struct MagicFunc(Stringable):
    var value: Float32

    fn __add__(self, other: MagicFunc) -> MagicFunc:
        return MagicFunc((self.value + other.value) * 2)

    fn __str__(self) -> String:
        return "MagicFunc(" + str(self.value) + ")"

fn print_result[result: MagicFunc](y_offset: Float32):
    print("Result: " + str(result))
    print("Result with offset: " + str(result. value + y_offset))

fn main():
    greet["world"]()

    # We can overload parameters
    greet["mom", 2]()

    # Cannot take dynamic values
    var name = String("John")
    # greet[name]() # Compile error, no dynamic values allowed

    # You can use compile-time values, such as aliases
    alias STRING_COMPILE_VALUE = String("John")
    greet[STRING_COMPILE_VALUE]()

    # even expressions of compile-time values
    greet[(STRING_COMPILE_VALUE + "-Doe-Martin").replace("-", " ")]()

    # Use custom struct and functions at compile-time parameters expressions evaluation
    print_result[MagicFunc(2.5) + MagicFunc(2)](10)