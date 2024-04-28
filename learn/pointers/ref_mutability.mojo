alias MUTABLE = __mlir_attr.`1: i1`
alias IMMUTABLE = __mlir_attr.`0: i1`

struct MutRef[T: AnyType]:
    alias Type = Reference[T, MUTABLE]

struct Ref[T: AnyType]:
    alias Type = Reference[T, IMMUTABLE]


struct Consumer:
    var source: Reference[Int, MUTABLE, ]

fn main():
    var x = 5
    var x2 = MutRef[Int].Type(x)   # a mutable reference to x
    x2[] = 12
    print("x = " + str(x))            # original x is modified by x2
    print("x2 = " + str(x2[]))

    var y = 5
    var y2 = Ref[Int].Type(y)   # an immutable reference to y
    # y2[] = 12  # error: cannot assign to immutable reference
    print("y = " + str(y))
    print("y2 = " + str(y2[]))

    # mojo allows multiple mutable references to the same variable contrary to languages like Rust
    var z = 5
    var z_1 = MutRef[Int].Type(z)
    var z_2 = MutRef[Int].Type(z)

    z_1[] = 10
    print("z = " + str(z))  # z is modified by z_1

    z_2[] = 20
    print("z = " + str(z))  # z is modified by z_2