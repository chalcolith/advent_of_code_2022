use "collections"
use "files"

class Dir
  let name: String
  let parent: (Dir | None)
  let entries: Array[Entry] = entries.create()
  var total_size: USize = 0

  new create(name': String, parent': (Dir | None)) =>
    name = name'
    parent = parent'

  fun compare(that: box->Dir): Compare =>
    if total_size < that.total_size then
      Less
    elseif total_size > that.total_size then
      Greater
    else
      Equal
    end

  fun lt(that: box->Dir): Bool => compare(that) is Less
  fun le(that: box->Dir): Bool => compare(that) isnt Greater
  fun ge(that: box->Dir): Bool => compare(that) isnt Less
  fun gt(that: box->Dir): Bool => compare(that) is Greater
  fun eq(that: box->Dir): Bool => compare(that) is Equal
  fun ne(that: box->Dir): Bool => compare(that) isnt Equal

type Entry is (Dir | (String, USize))

actor Main
  new create(env: Env) =>
    let file = File(FilePath(FileAuth(env.root), "input.txt"))

    let root = Dir("/", None)
    var pwd: (Dir | None) = None
    var num_dirs: USize = 1
    for line' in FileLines(file) do
      let line: String val = consume line'
      try
        if line.trim(0, 4) == "$ cd" then
          pwd = cd(line.trim(5), pwd, root)?
        elseif line.trim(0, 3) == "dir" then
          match pwd
          | let dir: Dir =>
            dir.entries.push(Dir(line.trim(4), dir))
            num_dirs = num_dirs + 1
          end
        elseif (line(0)? >= '0') and (line(0)? <= '9') then
          (let size, let next) = parse_number(line.trim(0), 0)
          match pwd
          | let dir: Dir =>
            dir.entries.push((line.trim(next + 1), size))
          end
        end
      end
    end
    let max_size: USize = 100_000
    let below_max = Array[USize]
    let sorted = MinHeap[Dir](num_dirs)
    get_total_size(root, max_size, below_max, sorted)

    var sum: USize = 0
    for total in below_max.values() do
      sum = sum + total
    end
    env.out.print("part1: " + sum.string()) // 1141028

    let disk_size: USize = 70_000_000
    let update_size: USize = 30_000_000
    let free_space = disk_size - root.total_size
    let min_size = update_size - free_space

    while sorted.size() > 0 do
      try
        let dir = sorted.pop()?
        if dir.total_size >= min_size then
          env.out.print("part2: " + dir.total_size.string()) // 8278005
          break
        end
      end
    end

  fun get_total_size(dir: Dir, max: USize, below_max: Array[USize], sorted: MinHeap[Dir]): USize =>
    var total: USize = 0
    for entry in dir.entries.values() do
      match entry
      | let subdir: Dir =>
        total = total + get_total_size(subdir, max, below_max, sorted)
      | (_, let size: USize) =>
        total = total + size
      end
    end
    dir.total_size = total
    sorted.push(dir)
    if total <= max then
      below_max.push(total)
    end
    total

  fun print(out: OutStream, dir: Dir, prefix: String) =>
    out.print(prefix + dir.name)
    let prefix' = recover val prefix + "  " end
    for entry in dir.entries.values() do
      match entry
      | let subdir: Dir =>
        print(out, subdir, prefix')
      | (let name: String, let size: USize) =>
        out.print(prefix' + size.string() + " " + name)
      end
    end

  fun cd(path: String, pwd: (Dir | None), root: Dir): Dir ? =>
    if path == "/" then
      root
    elseif path == ".." then
      (pwd as Dir).parent as Dir
    else
      for entry in (pwd as Dir).entries.values() do
        match entry
        | let dir: Dir if dir.name == path =>
          return dir
        end
      end
      error
    end

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
