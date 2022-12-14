use "files"

actor Main
  new create(env: Env) =>
    let file = File(FilePath(FileAuth(env.root), "input.txt"))

    let offset: ISize = 20
    let period: ISize = 40
    let width: ISize = 40

    var i: ISize = 0
    var op: String = ""
    var delta: ISize = 0
    var x: ISize = 1
    let buf = Array[ISize](4)

    var part1: ISize = 0
    var part2 = Array[String ref]

    let lines = FileLines(file)
    while i < 240 do
      i = i + 1

      if (i >= offset) and (((i - offset) % period) == 0) then
        let strength = i * x
        part1 = part1 + strength
      end

      let row = USize.from[ISize]((i-1) / width)
      let col = (i-1) % width

      while part2.size() < (row+1) do
        part2.push(String)
      end

      try
        part2(part2.size() - 1)?.push(
          if (col - x).abs() <= 1 then '#' else '.' end
        )
      end

      match op
      | "addx" =>
        x = x + delta
        op = ""
      else
        if lines.has_next() then
          try
            let line: String val = lines.next()?
            match line.trim(0, 4)
            | "noop" =>
              continue
            | "addx" =>
              (delta, _) = parse_number(line, 5)
              op = "addx"
            end
          end
        end
      end
    end

    env.out.print("part1: " + part1.string()) // 14860
    for row in part2.values() do
      env.out.print("part2: " + row) // RGZEHURK
    end

  fun parse_number(line: String, i: USize): (ISize, USize) =>
    try
      var next: USize = i
      while true do
        if (next == line.size()) or
            (not (
              (line(next)? == '-') or
              (line(next)? == '+') or
              ((line(next)? >= '0') and (line(next)? <= '9')
            ))
          )
        then
          return (line.trim(i, next).isize()?, next)
        end
        next = next + 1
      end
    end
    (0, 0)
