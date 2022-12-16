use "files"

actor Main
  let _env: Env

  new create(env: Env) =>
    _env = env
    let info = read_map(_env)

    _env.out.print("width: " + info.width.string())
    _env.out.print("hight: " + info.height.string())
    _env.out.print("start: (" + info.start._1.string() + ", " + info.start._2.string() + ")")
    _env.out.print("goal:  (" + info.goal._1.string() + ", " + info.goal._2.string() + ")")

    Searcher(info,
      {(best: ISize) =>
        _env.out.print("part1: " + best.string())
      })

  fun tag read_map(env: Env): MapInfo =>
    var width: ISize = 0
    var height: ISize = 0
    var start: (ISize, ISize) = (0, 0)
    var goal: (ISize, ISize) = (0, 0)

    let map' =
      recover val
        let file = File(FilePath(FileAuth(env.root), "input.txt"))
        let map = Array[ISize]

        var i: ISize = 0
        for line' in FileLines(file) do
          let line: String val = consume line'
          if line.size() == 0 then continue end

          if width == 0 then
            width = ISize.from[USize](line.size())
          end

          for ch in line.values() do
            if ch == 'S' then
              start = (ISize.from[USize](map.size()) % width, height)
              map.push(0)
            elseif ch == 'E' then
              goal = (ISize.from[USize](map.size()) % width, height)
              map.push(ISize.from[U8]('z' - 'a'))
            else
              map.push(ISize.from[U8](ch - 'a'))
            end
          end
          height = height + 1
        end
        map
      end
    MapInfo(width, height, map', start, goal)

class val MapInfo
  let width: ISize
  let height: ISize
  let map: Array[ISize] val
  let start: (ISize, ISize)
  let goal: (ISize, ISize)

  new val create(width': ISize, height': ISize, map': Array[ISize] val, start': (ISize, ISize), goal': (ISize, ISize)) =>
    width = width'
    height = height'
    map = map'
    start = start'
    goal = goal'
