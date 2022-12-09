use "collections"
use "files"

actor Main
  new create(env: Env) =>
    let part1 = Array[(ISize, ISize)].init((0, 0), 2)
    let p1_visit = HashSet[(ISize, ISize), CoordHash]
    p1_visit.set((0, 0))

    let part2 = Array[(ISize, ISize)].init((0, 0), 10)
    let p2_visit = HashSet[(ISize, ISize), CoordHash]
    p2_visit.set((0, 0))

    let file = File(FilePath(FileAuth(env.root), "input.txt"))
    for line' in FileLines(file) do
      let line: String val = consume line'
      try
        let ch = line(0)?
        (let n, _) = parse_number(line, 2)
        match ch
        | 'U' =>
          move(part1, 0, 1, n, p1_visit)
          move(part2, 0, 1, n, p2_visit)
        | 'D' =>
          move(part1, 0, -1, n, p1_visit)
          move(part2, 0, -1, n, p2_visit)
        | 'L' =>
          move(part1, -1, 0, n, p1_visit)
          move(part2, -1, 0, n, p2_visit)
        | 'R' =>
          move(part1, 1, 0, n, p1_visit)
          move(part2, 1, 0, n, p2_visit)
        end
      end
    end
    env.out.print("part1: " + p1_visit.size().string()) // 5710
    env.out.print("part2: " + p2_visit.size().string()) // 2259

  fun move(rope: Array[(ISize, ISize)], dx: ISize, dy: ISize, n: USize, visited: HashSet[(ISize, ISize), CoordHash]) =>
    for i in Range(0, n) do
      try
        let head = rope(0)?
        rope(0)? = (head._1 + dx, head._2 + dy)

        for j in Range(1, rope.size()) do
          rope(j)? = move_knot(rope(j-1)?, rope(j)?)
        end
        visited.set(rope(rope.size() - 1)?)
      end
    end

  fun move_knot(head: (ISize, ISize), tail': (ISize, ISize)): (ISize, ISize) =>
    var tail = tail'
    if (head._2 > (tail._2 + 1)) then // above
      if head._1 > tail._1 then // above right
        tail = (tail._1 + 1, tail._2 + 1)
      elseif head._1 < tail._1 then // above left
        tail = (tail._1 - 1, tail._2 + 1)
      else // just above
        tail = (tail._1, tail._2 + 1)
      end
    elseif (head._2 < (tail._2 - 1)) then // below
      if head._1 > tail._1 then // below right
        tail = (tail._1 + 1, tail._2 - 1)
      elseif head._1 < tail._1 then // below left
        tail = (tail._1 - 1, tail._2 - 1)
      else // just below
        tail = (tail._1, tail._2 - 1)
      end
    elseif (head._1 > (tail._1 + 1)) then // right
      if head._2 > tail._2 then // right above
        tail = (tail._1 + 1, tail._2 + 1)
      elseif head._2 < tail._2 then // right below
        tail = (tail._1 + 1, tail._2 - 1)
      else // just right
        tail = (tail._1 + 1, tail._2)
      end
    elseif (head._1 < (tail._1 - 1)) then // left
      if head._2 > tail._2 then // left above
        tail = (tail._1 - 1, tail._2 + 1)
      elseif head._2 < tail._2 then // left below
        tail = (tail._1 - 1, tail._2 - 1)
      else // just left
        tail = (tail._1 - 1, tail._2)
      end
    end
    tail

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

class val CoordHash is HashFunction[(ISize, ISize)]
  new val create() =>
    None

  fun hash(x: (ISize, ISize)): USize =>
    x._1.hash() xor x._2.hash()

  fun eq(x: (ISize, ISize), y: (ISize, ISize)): Bool =>
    (x._1 == y._1) and (x._2 == y._2)
