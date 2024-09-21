from sys.info import num_logical_cores, num_performance_cores

alias LS = List[Int](1, 2, 2, 1, 1, 2, 4)
alias N = len(LS)

alias W: Int = 16
alias S_MAX: Int = 2**31

fn main():
    alias W_WIDTH = S_MAX // W
    print("Number of logical cores:", W)
    print("width:", S_MAX // W)
    var p = SIMD[DType.int8, 4](5, 7 , 1, 0)
    var min_vol: UInt64 = 2**32
    print("LS:", min_vol)

    # var x = SIMD[DType.int32, 4](1, 0, 0, 0)
    # var y = SIMD[DType.int32, 4](1, 0, 0, 0)

    # var z = (x == y).reduce_and()

    # if z:
    #     print("x and y are equal")
    # else:
    #     print("x and y are not equal")

    # print(z)