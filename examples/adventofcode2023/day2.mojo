"""
day1.mojo
Mojo Version: 24.2.0
@description: Advent of Code 2024 - Day 2 Challenge in Mojo. Find valid games and calculate the power value for each game minimum items subset .
There are two parts in this challenge implemented in two functions: get_valid_games_p1 and get_games_min_power_value_p2.
Mojo Concepts:
- raises error forwarding
- List push and pop operations
"""

fn get_valid_games_p1(lines: List[String], t_red: Int, t_blue: Int, t_green: Int) raises -> List[Int]:
    """
    Get_valid_games_p1 function receives a list of strings and three integers. The function returns a list of integers.
    @param lines: A list of strings with the game information.
    @param t_red: An integer with the maximum number of red items.
    @param t_blue: An integer with the maximum number of blue items.
    @param t_green: An integer with the maximum number of green items.
    @return: A list of game ids that are valid.
    See https://adventofcode.com/2023/day/2 for more information.
    """
    var games = List[Int]()

    # Line Example "Game 1: 3 blue, 4 red; 1 red, 2 green, 6 blue; 2 green"
    for line in lines:
        var parts = line[].split(":")
        var n = parts[0][5:]
        var game_id = atol(n)
        var is_valid = True
        var subsets = parts[1].split(";")
        for subset in subsets:
            var items = subset[].split(",")
            for item_ref in items:
                var limit = -1
                var item = item_ref[].strip()
                var item_parts = item.split(" ")
                var color = item_parts[1]
                var count = atol(item_parts[0])
                if color == "red":
                    limit = t_red
                elif color == "blue":
                    limit = t_blue
                elif color == "green":
                    limit = t_green

                if count > limit:
                    is_valid = False
                    break
            if not is_valid:
                break

        if is_valid:
            games.append(game_id)
                    
    return games


fn get_games_min_power_value_p2(lines: List[String]) raises -> List[Int]:
    """
    Get_games_min_power_value_p2 function receives a list of strings. The function returns a list of integers.
    @param lines: A list of strings with the game information.
    @return: A list of integers with the power value for each game minimum subset.
    See https://adventofcode.com/2023/day/2 for more information.
    """
    var power_values = List[Int]()

    for line in lines:
        var min_red = 0
        var min_blue = 0
        var min_green = 0
        var parts = line[].split(":")
        var subsets = parts[1].split(";")

        for subset in subsets:
            var items = subset[].split(",")
            for item_ref in items:
                var item = item_ref[].strip()
                var item_parts = item.split(" ")
                var color = item_parts[1]
                var count = atol(item_parts[0])

                if color == "red" and count > min_red:
                    min_red = count
                elif color == "blue" and count > min_blue:
                    min_blue = count
                elif color == "green" and count > min_green:
                    min_green = count

        # print(min_red, min_blue, min_green)
        power_values.append(min_red*min_blue*min_green)
    
    return power_values

fn main() raises:
    print("Advent of Code 2023 - Day 2 Challenge")

    var t_red = 12
    var t_green = 13
    var t_blue = 14

    with open("day2.in4.txt", "r") as file:
        var lines = file.read().split("\n")

        # if last line is an empty string (as many files end with \n), remove it
        if len(lines[len(lines)-1]) == 0:
            _ = lines.pop_back()
        
        var results = get_valid_games_p1(lines, t_red, t_blue, t_green)
        # var results = get_games_min_power_value_p2(lines)

        # get the sum of games items
        var sum = 0
        for num in results:
            sum += num[]
        print(sum)

