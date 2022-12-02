use "files"

actor Main
  new create(env: Env) =>
    let scores: Array[Array[USize]] = [
      [ 4; 8; 3 ]
      [ 1; 5; 9 ]
      [ 7; 2; 6 ]
    ]

    var score_part1: USize = 0
    var score_part2: USize = 0

    let file = File(FilePath(FileAuth(env.root), "input.txt"))
    for line in FileLines(file) do
      try
        let first = USize.from[U8](line(0)? - 'A')
        let second = USize.from[U8](line(2)? - 'X')
        score_part1 = score_part1 + scores(first)?(second)?
        score_part2 = score_part2 + scores(first)?((first + second + 2) % 3)?
      end
    end

    env.out.print("part 1 = " + score_part1.string()) // 13005
    env.out.print("part 2 = " + score_part2.string()) // 11373
