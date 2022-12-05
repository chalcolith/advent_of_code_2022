use "files"
use "itertools"

actor Main
  new create(env: Env) =>
    let file = File(FilePath(FileAuth(env.root), "input.txt"))

    let self = this
    (let part1, let part2) = Iter[String](FileLines(file))
      .fold[(USize, USize)](
        (0, 0),
        {(acc, line) =>
          (let first, let second) = self.parse_input(consume line)

          (let p1: USize, let p2: USize) =
            if self.contains(first, second) then
              (1, 1)
            elseif self.overlaps(first, second) then
              (0, 1)
            else
              (0, 0)
            end
          (acc._1 + p1, acc._2 + p2)
        }
      )

    env.out.print("part1 = " + part1.string()) // 605
    env.out.print("part2 = " + part2.string()) // 914

  fun overlaps(first: (USize, USize), second: (USize, USize)): Bool =>
    // second starts inside first
    ((second._1 >= first._1) and (second._1 <= first._2)) or
    // second ends inside first
    ((second._2 >= first._1) and (second._2 <= first._2)) or
    // first starts inside second
    ((first._1 >= second._1) and (first._1 <= second._2)) or
    // first ends inside second
    ((first._2 >= second._1) and (first._2 <= second._2))

  fun contains(first: (USize, USize), second: (USize, USize)): Bool =>
    ((second._1 >= first._1) and (second._2 <= first._2)) or
    ((first._1 >= second._1) and (first._2 <= second._2))

  fun parse_input(line: String): ((USize, USize), (USize, USize)) =>
    var next: USize = 0
    (let a, next) = parse_number(line, 0)
    (let b, next) = parse_number(line, next + 1)
    (let c, next) = parse_number(line, next + 1)
    (let d, next) = parse_number(line, next + 1)

    ((a, b), (c, d))

  fun parse_number(line: String, i: USize): (USize, USize) =>
    try
      var next: USize = i
      while true do
        if (next == line.size()) or
          (not ((line(next)? >= '0') and (line(next)? <= '9')))
        then
          return (line.trim(i, next).usize()?, next)
        end
        next = next + 1
      end
    end
    (0, 0)
