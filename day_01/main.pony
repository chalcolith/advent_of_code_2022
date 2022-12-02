use "collections"
use "files"

actor Main
  new create(env: Env) =>
    let file = File(FilePath(FileAuth(env.root), "input.txt"))

    let totals = BinaryHeap[USize, MaxHeapPriority[USize]](1000)
    var cur: USize = 0

    for line in FileLines(file) do
      if line.size() == 0 then
        totals.push(cur)
        cur = 0
      else
        try
          cur = cur + line.usize()?
        end
      end
    end

    totals.push(cur)

    try
      env.out.print("part1 = " + totals.peek()?.string()) // 68467
      let top_three = totals.pop()? + totals.pop()? + totals.pop()?
      env.out.print("part2 = " + top_three.string()) // 203420
    end
