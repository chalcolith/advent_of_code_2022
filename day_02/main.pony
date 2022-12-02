use "files"
use "itertools"

actor Main
  new create(env: Env) =>
    let scores: Array[Array[USize]] = [
      [ 4; 8; 3 ]
      [ 1; 5; 9 ]
      [ 7; 2; 6 ]
    ]

    let file = File(FilePath(FileAuth(env.root), "input.txt"))

    (let part1, let part2) = Iter[String](FileLines(file))
      .fold[(USize, USize)](
        (0, 0),
        {(acc, line) =>
          try
            let first = USize.from[U8](line(0)? - 'A')
            let second = USize.from[U8](line(2)? - 'X')
            ( acc._1 + scores(first)?(second)?,
              acc._2 + scores(first)?((first + second + 2) % 3)? )
          else
            acc
          end
        })

    env.out.print("part 1 = " + part1.string()) // 13005
    env.out.print("part 2 = " + part2.string()) // 11373
