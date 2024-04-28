
fn modify_var(inout x: Int):
    x = x + 1
    print("modify_var.x = " + str(x))

struct Foo:
    var x: Int
    var y: Int
    var name: String

    fn __init__(inout self, x: Int, y: Int):
        self.x = x
        self.y = y
        self.name = "Foo"

    fn add(inout self, other: Foo) -> None:
        self.x = self.x + other.x
        self.y = self.y + other.y


fn main():
    var x = 5
    var x2 = Reference(x)   # a reference to x with same mutability and lifetime as x in the current scope
    x2[] = 12
    print("x = " + str(x))            # original x is modified by x2
    print("x2 = " + str(x2[]))

    var y = 10
    modify_var(y)
    print("y = " + str(y))           # original y is modified by modify_var



    var s_int = sizeof[Foo]()
    var s_refint = sizeof[Ref[Foo].Type]()
    print("sizeof[Int] = " + str(s_int))
    print("sizeof[Reference[Int]] = " + str(s_refint))