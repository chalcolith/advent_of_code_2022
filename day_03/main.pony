use "collections/persistent"
use "files"
use "itertools"

actor Main
  new create(env: Env) =>
    let file = File(FilePath(FileAuth(env.root), "input.txt"))

    let process_chars: {(Set[USize], U8): Set[USize]} box =
      {(acc: Set[USize], ch: U8) =>
        if (ch >= 'a') and (ch <= 'z') then
          acc.add(1 + USize.from[U8](ch - 'a'))
        elseif (ch >= 'A') and (ch <= 'Z') then
          acc.add(27 + USize.from[U8](ch - 'A'))
        else
          acc
        end
      }

    let vec3 = Vec[Set[USize]].push(Set[USize]).push(Set[USize]).push(Set[USize])

    (let part1, let part2, _, _) = Iter[String](FileLines(file))
      .fold[(USize, USize, Vec[Set[USize]], USize)](
        (0, 0, vec3, 0), // part1, part2, sacks, n
        {(acc, line) =>
          let part1 = acc._1
          let part2 = acc._2
          let sacks = acc._3
          let n = acc._4

          let chars = Iter[U8](line.values())
          let half1 = Iter[U8](chars.take(line.size() / 2))
            .fold[Set[USize]](Set[USize], process_chars)
          let half2 = Iter[U8](chars)
            .fold[Set[USize]](Set[USize], process_chars)

          try
            let part1' = part1 + (half1 and half2).values().next()?
            let sacks' = sacks.update(n % 3, half1 or half2)?
            let part2' =
              if ((n+1) % 3) == 0 then
                part2 + (sacks'(0)? and sacks'(1)? and sacks'(2)?).values().next()?
              else
                part2
              end
            (part1', part2', sacks', n + 1)
          else
            acc
          end
        }
      )

    env.out.print("part1 = " + part1.string()) // 7785
    env.out.print("part2 = " + part2.string()) // 2633
