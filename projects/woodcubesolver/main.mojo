import sys
from algorithm import parallelize

alias W: Int = 16
alias S_MAX: Int = 2**32

alias SIMD_4u8_MAX = SIMD[DType.int8, 4](127, 127, 127, 0)
alias SIMD_4u8_MIN = SIMD[DType.int8, 4](-127, -127, -127, 0)

alias EDGES = List[Int32](
    0, 0, 0,
    1, 1,
    2, 2,
    3, 3,
    4,
    5,
    6,
    7, 7,
    8, 8,
    9,
    10,
    11, 11,
    12,
    13, 13,
    14,
    15,
    16, 16
)

alias MIN_VOL = 27

alias N = len(EDGES)

alias P_X = SIMD[DType.int8, 4]( 1,0,0,0)
alias N_X = SIMD[DType.int8, 4](-1,0,0,0)
alias P_Y = SIMD[DType.int8, 4](0, 1,0,0)
alias N_Y = SIMD[DType.int8, 4](0,-1,0,0)
alias P_Z = SIMD[DType.int8, 4](0,0, 1,0)
alias N_Z = SIMD[DType.int8, 4](0,0,-1,0)

alias P_X_DIRS = List[SIMD[DType.int8, 4]](
    P_Y, P_Z, N_Y, N_Z
)
alias N_X_DIRS = List[SIMD[DType.int8, 4]](
    N_Y, N_Z, P_Y, P_Z
)
alias P_Y_DIRS = List[SIMD[DType.int8, 4]](
    P_Z, P_X, N_Z, N_X
)
alias N_Y_DIRS = List[SIMD[DType.int8, 4]](
    N_Z, N_X, P_Z, P_X
)
alias P_Z_DIRS = List[SIMD[DType.int8, 4]](
    P_X, P_Y, N_X, N_Y
)
alias N_Z_DIRS = List[SIMD[DType.int8, 4]](
    N_X, N_Y, P_X, P_Y
)


fn get_dir(x_e: SIMD[DType.int32, 1], prev_d: SIMD[DType.int8, 4]) -> SIMD[DType.int8, 4]:
    if prev_d[0] > 0:
        return P_X_DIRS[x_e.value]
    elif prev_d[0] < 0:
        return N_X_DIRS[x_e.value]
    elif prev_d[1] > 0:
        return P_Y_DIRS[x_e.value]
    elif prev_d[1] < 0:
        return N_Y_DIRS[x_e.value]
    elif prev_d[2] > 0:
        return P_Z_DIRS[x_e.value]
    elif prev_d[2] < 0:
        return N_Z_DIRS[x_e.value]
    else:
        print("prev_d.x,y,z are zero!")
        sys.exit()
        return SIMD[DType.int8, 4](0,0,0,0)

fn make_dirs(sol: Int32, inout dirs: DTypePointer[DType.int8]):
    var e: Int32 = 0
    var x_e: Int32 = 0
    var prev_d = P_X
    for i in range(3, N):
        if EDGES[i] > e:
            e = EDGES[i]
            x_e = (sol >> ((e-1) << 1)) & SIMD[DType.int32, 1](3)
            prev_d = get_dir(x_e, prev_d)
        dirs.store[width=4](i*4, prev_d)

fn is_pos_duplicated(pos: SIMD[DType.int8, 4], index: Int, cubes: DTypePointer[DType.int8]) -> Bool:
    for i in range(index):
        if (pos == cubes.load[width=4](i*4)).reduce_and():
            return True
    return False

fn pos_coord(pos: SIMD[DType.int8, 4]) -> String:
    return "(" + str(pos[0]) + "," + str(pos[1]) + "," + str(pos[2]) + ")"

fn main():
    var argv = sys.argv()
    var output_file: String = "solution.txt"
    var target_vol: Int = MIN_VOL
    if len(argv) > 1:
        output_file = argv[1]
    if len(argv) > 2:
        try:
            target_vol = atol(str(argv[2]))
        except:
            print("Invalid target volume")
            sys.exit()
    print(sys.argv()[1])
    print("Output file:")
    print("Num of workers:", W)


    var g_min_volumes = SIMD[DType.int16, W](0)
    var g_best_solutions = SIMD[DType.uint32, W](0)
    var g_cubes = DTypePointer[DType.int8].alloc(4*N * W)

    var W_WIDTH = S_MAX // W

    var found = False

    @parameter
    fn kernel_fn(w_idx: Int):
        var cubes = DTypePointer[DType.int8].alloc(4*N)
        var max_p = SIMD_4u8_MIN
        var min_p = SIMD_4u8_MAX
        var dir   = DTypePointer[DType.int8].alloc(4*N)
        var min_vol: Int16 = 2**14
        var best_sol: Int = 0

        for i in range(N):
            cubes.store[width=4](i*4, 0)
            dir.store[width=4](i*4, 0)
        dir.store[width=4](0*4, P_X)
        dir.store[width=4](1*4, P_X)
        dir.store[width=4](2*4, P_X)

        for s in range(w_idx*W_WIDTH, (w_idx + 1) * W_WIDTH):
            ## CRITICAL SECTION
            if found:
                break
            make_dirs(s, dir) #TODO: Optimize

            var is_valid = True
            max_p = 0
            min_p = 0

            for i in range(1, N): #TODO: Optimize
                cubes.store[width=4](i*4, cubes.load[width=4]((i-1)*4) + dir.load[width=4](i*4))
                if is_pos_duplicated(cubes.load[width=4](i*4), i, cubes): #TODO: Optimize
                    is_valid = False
                    break

                max_p = max(max_p, cubes.load[width=4](i*4))
                min_p = min(min_p, cubes.load[width=4](i*4))

            if not is_valid:
                continue

            var max_p_16 = max_p.cast[DType.int16]()
            var min_p_16 = min_p.cast[DType.int16]()
            var vol = (max_p_16 - min_p_16 + 1).reduce_mul()
            if vol < min_vol:
                min_vol = vol
                best_sol = s
                print("WID (" + str(w_idx) + ") min_vol: ", min_vol)

                if min_vol <= target_vol:
                    found = True
                    break

        g_min_volumes[w_idx] = min_vol
        g_best_solutions[w_idx] = best_sol

        # Copy cubes to g_cubes
        for i in range(N):
            var g_index = (w_idx*N + i)
            g_cubes.store[width=4](g_index*4, cubes.load[width=4](i*4))

        cubes.free()
        dir.free()

    parallelize[kernel_fn](W, W)

    var index_of_min = 0
    for i in range(W):
        if g_min_volumes[i] < g_min_volumes[index_of_min]:
            index_of_min = i

    print("Best solution: ", g_best_solutions[index_of_min])
    print("Min vol: ", g_min_volumes[index_of_min])
    for i in range(N):
        var g_index = (index_of_min*N + i)
        print("cubes[", i, "]: ", g_cubes.load[width=4](g_index*4))

    try:
        with open(output_file, "w") as f:
            f.write("Best solution: " + str(g_best_solutions[index_of_min]) + "\n")
            f.write("min_vol: " + str(g_min_volumes[index_of_min]) + "\n")
            for i in range(N):
                var g_index = (index_of_min*N + i)
                f.write("cubes[" + str(i) + "]: " + pos_coord(g_cubes.load[width=4](g_index*4)) + "\n")
    except:
        print("Error while writing to best_solution.txt")

    g_cubes.free()