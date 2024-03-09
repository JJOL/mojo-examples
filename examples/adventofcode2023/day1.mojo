"""
day1.mojo
@description: Advent of Code 2024 - Day 1 Challenge in Mojo. Find the value for each string.
There are two parts in this challenge implemented in two functions: get_calibr_value_p1 and get_calibr_value_p2.
"""

# Note: I wanted to use a stack memory based structure like a Buffer, but afaik Buffer only with primitive register types
# and i didnt want to implement string "startswith" functions manually.
# So, I used a DynamicVector and initialized in main()
var STR_DIGITS: DynamicVector[String] = DynamicVector[String]()

fn get_calibr_value_p1(lines: DynamicVector[String]) -> Int:
    """
    Get_calibr_value - Get the callibration value for each document.
    :param lines: DynamicVector[String] - The lines of the document
    :return: Int - The callibration value
    See https://adventofcode.com/2023/day/1 for more information.
    """
    var acc = 0
    var offset = ord("0")
    for line in lines:
        var first = -1
        var last = -1
        var chars = line[].as_bytes()
        # Uses internal byte array to iterate over the characters

        for c in chars:
            var val = c[] - offset
            if val >= 0 and val <= 9:
                if first == -1:
                    first = val.to_int()
                last = val.to_int()

        acc += 10 * first + last
            
    return acc

fn is_digit(char_str: String, inout digit_val: Int) -> Bool:
    """
    Is_digit - Check if the character is a digit.
    :param char_str: String - The character to check
    :param inout digit_val: Int - The variable to store the digit value
    :return: Bool - True if the character is a digit, False otherwise.
    """
    var char_ord = ord(char_str)

    # Note: I hope ord("9") and ord("9") are being optimized by the compiler as constants
    if char_ord >= ord("0") and char_ord <= ord("9"):
        digit_val = char_ord - ord("0")
        return True
    else:
        digit_val = -1
        return False
        
fn get_calibr_value_p2(lines: DynamicVector[String]) -> Int:
    """
    Get_calibr_value_p2 - Get the callibration value for each document parsing digit string representations too.
    :param lines: DynamicVector[String] - The lines of the document
    :return: Int - The callibration value
    See https://adventofcode.com/2023/day/1 for more information.
    """
    var acc = 0
    
    for line_ref in lines:
        var line = line_ref[]
        var first = -1
        var last = -1
        var j = 0

        while j < len(line):
            var digit_val = -1

            if is_digit(line[j], digit_val):
                j += 1
            else:
                for k in range(len(STR_DIGITS)):
                    if line[j:].startswith(STR_DIGITS[k]):
                        digit_val = k
                        j += len(STR_DIGITS[k])
                        break
                if digit_val == -1:
                    j += 1

            if digit_val != -1:
                if first == -1:
                    first = digit_val
                last = digit_val

        acc += 10 * first + last
            
    return acc    

fn main():
    # Initialize "constant" digit string representations array
    STR_DIGITS.append("zero")
    STR_DIGITS.append("one")
    STR_DIGITS.append("two")
    STR_DIGITS.append("three")
    STR_DIGITS.append("four")
    STR_DIGITS.append("five")
    STR_DIGITS.append("six")
    STR_DIGITS.append("seven")
    STR_DIGITS.append("eight")
    STR_DIGITS.append("nine")

    try:
        # var file = open("1.in1.txt", "r")
        var file = open("1.in2.txt", "r")
        var content = file.read()

        var lines = content.split("\n")
        # print(get_calibr_value_p1(lines))
        print(get_calibr_value_p2(lines))

        file.close()
    except e:
        print(e)