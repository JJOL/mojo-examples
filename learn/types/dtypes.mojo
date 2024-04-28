
alias T =DType.uint16

fn _assert(value: Bool, message: StringLiteral) raises -> None:
    if not value:
        raise Error(message)


fn execute_on_integral[type: DType]() capturing -> None:
    print("I get executed on integral types")

fn execute_on_floating[type: DType]() capturing -> None:
    print("I get executed on floating types")

fn main() raises:
    # DType values store representations of basic data types
    var u8_type: DType = DType.uint8
    print("Value of u8_type is:", str(u8_type))

    # variables can be reasigned to other DType values
    u8_type = DType.float16
    print("Value of u8_type is:", str(u8_type))
    u8_type = DType.uint8

    # static DType's can be used to pointers and memory allocation
    var u8_ptr: DTypePointer[DType.uint8] = DTypePointer[DType.uint8].alloc(10)
    for i in range(10):
        u8_ptr[i] = i*2
    for i in range(10):
        print("u8_ptr[", i, "] = ", u8_ptr[i])

    # dynamic values of DType's can not be used create pointers
    # var u8_ptr2 = DTypePointer[u8_ptr].alloc(10)

    # sizeof a DType is 1 byte => it has 256 possible values
    _assert(sizeof[DType]() == 1, "")
    # but size of a DType value is the sizeof() representation of the value
    _assert(sizeof[DType.uint8]() == 1, "")
    _assert(sizeof[DType.uint16]() == 2, "")
    _assert(sizeof[DType.uint32]() == 4, "")

    # sizeof a pointer of a dtype, is the size of a plain pointer in the architecture
    _assert(sizeof[DTypePointer[DType.uint8]]() == 8, "")
    _assert(sizeof[DTypePointer[DType.uint16]]() == 8, "")
    _assert(sizeof[DTypePointer[DType.uint32]]() == 8, "")


    # Know sizeof of dynamic DType values
    _assert(u8_type.sizeof() == 1, "")

    u8_type = DType.float64
    if u8_type.is_integral():
        u8_type.dispatch_integral[execute_on_integral]()
    elif u8_type.is_floating_point():
        u8_type.dispatch_floating[execute_on_floating]()