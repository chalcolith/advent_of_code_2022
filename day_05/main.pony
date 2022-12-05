use "files"
use "collections"

actor Main
  let _env: Env
  let _stacks1: Array[Array[U8]] = _stacks1.create()
  let _stacks2: Array[Array[U8]] = _stacks2.create()

  new create(env: Env) =>
    _env = env

    let file = File(FilePath(FileAuth(env.root), "input.txt"))

    for line in FileLines(file) do
      if line.contains("[") then
        handle_setup(consume line)
      elseif line.contains("move") then
        handle_move(consume line)
      end
    end

    let part1 = String
    try
      for stack in _stacks1.values() do
        if stack.size() > 0 then
          part1.push(stack(stack.size() - 1)?)
        end
      end
    end
    _env.out.print("part1 = " + part1) // FWSHSPJWM

    let part2 = String
    try
      for stack in _stacks2.values() do
        if stack.size() > 0 then
          part2.push(stack(stack.size() - 1)?)
        end
      end
    end
    _env.out.print("part2 = " + part2) // PWPWHGFZS

  fun ref handle_setup(line: String) =>
    var i: USize = 1
    while i < line.size() do
      try
        let ch = line(i)?
        if (ch >= 'A') and (ch <= 'Z') then
          let stack_index = (i - 1) / 4
          while _stacks1.size() < (stack_index + 1) do
            _stacks1.push(Array[U8])
            _stacks2.push(Array[U8])
          end
          _stacks1(stack_index)?.unshift(ch)
          _stacks2(stack_index)?.unshift(ch)
        end
      end
      i = i + 4
    end

  fun ref handle_move(line: String) =>
    var next: USize = 0
    (let num, next) = parse_number(line, 5)
    (let src, next) = parse_number(line, next + 6)
    (let dest, next) = parse_number(line, next + 4)

    try
      let ss = _stacks1(src-1)?
      let sl = ss.size() - 1

      let ds = _stacks1(dest-1)?

      for i in Range(0, num) do
        ds.push(ss(sl - i)?)
      end
      ss.trim_in_place(0, ss.size() - num)
    end

    try
      let ss = _stacks2(src-1)?
      let sl = ss.size() - num

      let ds = _stacks2(dest-1)?

      for i in Range(0, num) do
        ds.push(ss(sl + i)?)
      end
      ss.trim_in_place(0, ss.size() - num)
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
