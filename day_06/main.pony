use "files"
use "format"
use "collections"

actor Main
  new create(env: Env) =>
    let file = File(FilePath(FileAuth(env.root), "input.txt"))

    for line in FileLines(file) do
      let line': String val = consume line
      env.out.print("part1: " + process_line(line', 4).string()) // 1538
      env.out.print("part2: " + process_line(line', 14).string()) // 2315
    end

  fun process_line(line: String, num: USize): USize =>
    try
      var buf = Array[U8].init(0, num)
      for i in Range(0, line.size()) do
        let ch = line(i)?

        buf(i % buf.size())? = ch

        if (i+1) >= buf.size() then
          let dup =
            for j in Range(0, buf.size()) do
              let a = buf(j % buf.size())?

              let dup' =
                for k in Range(1, buf.size()) do
                  let b = buf((j+k) % buf.size())?
                  if a == b then
                    break true
                  end
                  false
                else
                  false
                end
              if dup' then
                break true
              end
              false
            else
              false
            end
          if not dup then
            return i+1
          end
        end
      end
    end
    0
