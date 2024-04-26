"""
day3.mojo
Mojo Version: 24.2.0
@description: Advent of Code 2024 - Day 3 Challenge in Mojo. Parse engine schematics for parts and gears to calculate their values.
There are two parts in this challenge implemented in two functions: PartsInfo::engine_parts_value() and PartsInfo::engine_gears_ratio_value.
Both of these GearInfo functions greatly depend on parsing the input with PartsInfo::from_schematic().
See https://adventofcode.com/2023/day/3 for more information.

Mojo Concepts:
- Structs
- CollectionItems and Movable Structs
- Value Structs
- Struct static methods
- aliases
"""

import math
import sys

alias _10 = SIMD[DType.uint16, 1](10)
alias NULL_PART = -1

fn is_symbol(c: String) -> Bool:
    return not isdigit(c._buffer[0]) and c != '.'

fn count_neighbours(lines: List[String], x: Int, y: Int, test_fn: fn(String)->Bool) -> Int:
    """
    Count the number of adjacent neighbours to location x,y (max 8) that satisfy the test function.
    """
    var neighbours = 0
    
    # Logic to check the 8 neighbours. If rules are for handling the edges when neighbours might not exist
    if y > 0:
        if x > 0:
            if test_fn(lines[y - 1][x - 1]):
                neighbours += 1
        if test_fn(lines[y - 1][x]):
            neighbours += 1
        if x < len(lines[y]) - 1:
            if test_fn(lines[y - 1][x + 1]):
                neighbours += 1
    if x > 0:
        if test_fn(lines[y][x - 1]):
            neighbours += 1
    if x < len(lines[y]) - 1:
        if test_fn(lines[y][x + 1]):
            neighbours += 1
    if y < len(lines) - 1:
        if x > 0:
            if test_fn(lines[y + 1][x - 1]):
                neighbours += 1
        if test_fn(lines[y + 1][x]):
            neighbours += 1
        if x < len(lines[y]) - 1:
            if test_fn(lines[y + 1][x + 1]):
                neighbours += 1
    return neighbours

fn has_symbol_neighbours(lines: List[String], x: Int, y: Int) -> Bool:
    """
    Check if the location x,y has any adjacent neighbours that are symbols (not digits or '.').
    """
    var neighbours = count_neighbours(lines, x, y, is_symbol) # is_symbol is a function pointer that checks if a string is a symbol
    return neighbours > 0

fn has_element(list: List[Int], element: Int) -> Bool:
    """
    Check if the list contains the element.
    """
    for el in list:
        if el[] == element:
            return True
    return False

@value
struct Location:
    var x: UInt32
    var y: UInt32

@value
struct GearInfo(CollectionElement):
    var location: Location
    var gear_ratio: Int

    def __init__(inout self, x: Int, y: Int):
        self.location = Location(x, y)
        self.gear_ratio = 0


struct PartsInfo:
    var part_values: List[Int]
    var part_locations: DTypePointer[DType.int32]
    var gears: List[GearInfo]
    var height: Int
    var width: Int

    fn __init__(inout self, height: Int, width: Int):
        self.height = height
        self.width = width
        self.part_locations = DTypePointer[DType.int32].alloc(height * width)
        for i in range(height * width):
            self.part_locations[i] = NULL_PART

        self.part_values = List[Int]()

        self.gears = List[GearInfo]()

    fn __moveinit__(inout self, owned other: Self):
        """
        Move constructor to move the values from another PartsInfo instance. (Useful when returning from a function or moving a value to another variable).
        """
        self.part_values = other.part_values^
        self.part_locations = other.part_locations
        self.height = other.height
        self.width = other.width
        self.gears = other.gears^

    fn print_part_locations(self):
        """
        Print the part locations matrix to see the internal part indices.
        """
        print('Part Indices Location Matrix')
        var s = String("")
        for i in range(self.height):
            for j in range(self.width):
                var part = self.part_locations[i * self.width + j]
                if part == NULL_PART:
                    s += '.'
                else:
                    s += str(part)
                if j < self.width - 1:
                    s += ' '
            s += '\n'
        print(s)

    fn get_part_value_at(self, x: Int, y: Int) -> Int:
        """
        Get the part value at location x,y. If there is no part at that location 
        or the location is out of bounds, return NULL_PART.
        """
        if x < 0 or x >= self.width or y < 0 or y >= self.height:
            return NULL_PART

        var part_index = self.part_locations[y * self.width + x].to_int()
        if part_index == NULL_PART:
            return NULL_PART
        
        return self.part_values[part_index]

    fn engine_parts_value(self) -> Int:
        """
        Calculate the total value of all the parts in the engine.
        """
        var total_value = 0
        for part_val in self.part_values:
            total_value += part_val[]
        return total_value

    fn engine_gears_ratio_value(self) -> Int:
        """
        Calculate the total value of all the gear ratios in the engine.
        """
        var total_value = 0
        for gear in self.gears:
            if gear[].gear_ratio > 0:
                total_value += gear[].gear_ratio
        return total_value

    fn find_neighbour_parts(self, x: Int, y: Int) -> List[Int]:
        """
        Find the unique parts (values) within the 8 neighbours of location x,y.
        """
        var all_neighbour_parts = List[Int]()

        # Check 8 neighbours to see what part values are there
        all_neighbour_parts.append(self.get_part_value_at(x - 1, y - 1))
        all_neighbour_parts.append(self.get_part_value_at(x, y - 1))
        all_neighbour_parts.append(self.get_part_value_at(x + 1, y - 1))
        all_neighbour_parts.append(self.get_part_value_at(x - 1, y))
        all_neighbour_parts.append(self.get_part_value_at(x + 1, y))
        all_neighbour_parts.append(self.get_part_value_at(x - 1, y + 1))
        all_neighbour_parts.append(self.get_part_value_at(x, y + 1))
        all_neighbour_parts.append(self.get_part_value_at(x + 1, y + 1))

        # Remove the NULL_PART parts and duplicates to get unique part values
        var unique_neighbour_parts = List[Int]()
        for part in all_neighbour_parts:
            if part[] != NULL_PART and not has_element(unique_neighbour_parts, part[]):
                unique_neighbour_parts.append(part[])

        return unique_neighbour_parts^

    fn find_gear_ratios(inout self):
        """
        Find the gear ratios for all the gears in the engine. A gear requires 2 part neighbours to calculate the gear ratio.
        """
        for gear in self.gears:
            var loc = gear[].location
            # print("Gear at: ", str(loc.x), ", ", str(loc.y))
            var neighbour_parts = self.find_neighbour_parts(loc.x.to_int(), loc.y.to_int())
            if len(neighbour_parts) == 2:
                # print('Has 2 neighbours: ', str(neighbour_parts[0]), ', ', str(neighbour_parts[1]))
                gear[].gear_ratio = neighbour_parts[0] * neighbour_parts[1]
                # print('Gear ratio: ', str(gear[].gear_ratio))
            

    @staticmethod
    fn from_schematic(lines: List[String]) raises -> PartsInfo:
        """
        Parse the engine schematic from the input lines and create a PartsInfo instance with parts and gears.
        """
        var parts_info = PartsInfo(len(lines), len(lines[0]))

        # Find parts by constructing part_values based on part rules and store their locations in part_locations matrix
        # A part is a decimal-based number that has at least one symbol neighbour (not a digit or '.')
        # The algorithm is a one-pass scan of the input lines to generate part values, test conditions and store part locations
        for i in range(len(lines)):
            var is_part_number = False
            var part_value = 0
            var number_size = 0

            # Read each line from right to left to easily compute decimal values from digits as we go
            for j in range(len(lines[i]) - 1, -1, -1):
                var c = lines[i][j]
                
                if isdigit(c._buffer[0]):
                    var digit = atol(c)
                    part_value += digit * math.pow(_10, number_size).to_int()
                    number_size += 1

                    if has_symbol_neighbours(lines, j, i):
                        is_part_number = True

                    if j == 0 or not isdigit(lines[i][j - 1]._buffer[0]):
                        # Finished reading number string. Either add to part_values and mark it in location or not
                        if is_part_number:
                            parts_info.part_values.append(part_value)
                            var part_index = len(parts_info.part_values) - 1
                            
                            # Mark the part location in the parts_location matrix
                            for k in range(number_size):
                                var loc_ind = i * parts_info.width + (j + k)
                                parts_info.part_locations[loc_ind] = part_index

                        # print("Found part number: ", str(part_value))
                
                        # Reset for next number
                        number_size = 0
                        part_value = 0
                        is_part_number = False

                elif c == '*':
                    # print("Found * at: ", str(i), ", ", str(j))
                    parts_info.gears.append(GearInfo(j, i))
            
        # Find and apply gear ratios for all the gears in the engine
        parts_info.find_gear_ratios()

        return parts_info^

fn main() raises:
    print("Advent of Code 2023 - Day 3 Challenge")

    var file_name: String = ""
    var argv = sys.argv()
    if len(argv) > 1:
        file_name = argv[1]
    else:
        file_name = "day3.in1.txt"

    # Super Fast in memory string parsing for testing
    # var file_content = String("""467..114..
# ...*......
# ..35..633.
# ......#...
# 617*......
# .....+.58.
# ..592.....
# ......755.
# ...$.*....
# .664.598..""")
#     var lines = file_content.split("\n")
#     var parts_info = PartsInfo.from_schematic(lines)
#     var final_value = parts_info.engine_parts_value()
#     print("Final Parts value: ", str(final_value))
#     var gear_ratio_value = parts_info.engine_gears_ratio_value()
#     print("Gear ratio value: ", str(gear_ratio_value))


    with open(file_name, "r") as file:
        var content = file.read()
        var lines = content.split("\n")

        var parts_info = PartsInfo.from_schematic(lines)

        var final_value = parts_info.engine_parts_value()
        print("Final Parts value: ", str(final_value))

        var gear_ratio_value = parts_info.engine_gears_ratio_value()
        print("Gear ratio value: ", str(gear_ratio_value))


        # Print part indices mask matrix to see internals (readable output if there are at most 10 parts)
        # print("")
        # parts_info.print_part_locations()