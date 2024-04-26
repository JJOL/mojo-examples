"""
day4.mojo
Mojo Version: 24.1.0
@description: Advent of Code 2024 - Day 3 Challenge in Mojo. <>.
There are two parts in this challenge implemented in two functions: <>.
<>.
See https://adventofcode.com/2023/day/4 for more information.

Mojo Concepts:
- 
"""

from lib.logging import Logger
from lib.lists import Ball
fn main():
    var logger = Logger.get(level=Logger.DEBUG)
    # logger.info("Advent of Code 2023 - Day 4 Challenge")
    # var s1 = String("L")
    # var s2 = String("JALGO")
    # var s3 = String("-")
    # var s4 = String("Jalgo")
    # logger.debug(str(s2[0] == s4[0]))


    var list = Ball[Float32]()

    var e1 = list.append(23)
    var e2 = list.append(24.5)
    var e3 = list.append(55)
    var e4 = list.append(2)

    print("List Length: ", len(list))
    if e3 in list:
        print("Element 55 is in the list")
    else:
        print("Element 55 is not in the list")

    var e3_value = list._ref(e3)[].value
    print("Value at e3: ", e3_value)

    list.remove(e3)
    print("List Length: ", len(list))

    if e3 in list:
        print("Element 55 is not in the list")
    else:
        print("Element 55 is not in the list")
    # var first_element = list.begin().value()
    # var current = list.begin().value()
    # while list.next(current).value() != first_element:
    #     print(list[current])
    #     current = list.next(current).value()