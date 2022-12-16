use "collections"

actor Searcher
  let _width: ISize
  let _height: ISize
  let _map: Array[ISize] val
  let _start: (ISize, ISize)
  let _goal: (ISize, ISize)

  let _vis: Array[Bool]
  let _queue: List[PathStep]
  let _results: Array[PathStep]
  let _report: {(ISize)} iso

  new create(info: MapInfo, report: {(ISize)} iso^)
  =>
    _width = info.width
    _height = info.height
    _map = info.map
    _start = info.start
    _goal = info.goal
    _report = report

    _vis = Array[Bool].init(false, _map.size())
    try
      let sdx = USize.from[ISize]((_start._2 * _width) + _start._1)
      _vis(sdx)? = true
    end
    _queue = List[PathStep]
    _queue.push(PathStep(None, _start, 0))
    _results = Array[PathStep]

    do_step(0)

  be do_step(iteration: USize) =>
    if _queue.size() > 0 then
      try
        let step = _queue.pop()?
        (let x, let y) = step.pos

        if (x == _goal._1) and (y == _goal._2) then
          _results.push(step)
        else
          enqueue_if_valid(step, (x, y-1))
          enqueue_if_valid(step, (x, y+1))
          enqueue_if_valid(step, (x+1, y))
          enqueue_if_valid(step, (x-1, y))
        end
        do_step(iteration + 1)
      end
    else
      if _results.size() > 0 then
        try
          var best = _results(0)?
          for result in _results.values() do
            if result.length < best.length then
              best = result
            end
          end
          _report(best.length)
        end
      end
    end

  fun ref enqueue_if_valid(parent: PathStep, dest: (ISize, ISize)) =>
    (let x1, let y1) = parent.pos
    (let x2, let y2) = dest

    if (x2 >= 0) and (x2 < _width) and (y2 >= 0) and (y2 < _height) then
      let idx1 = USize.from[ISize]((y1 * _width) + x1)
      let idx2 = USize.from[ISize]((y2 * _width) + x2)

      // var cur = step
      // while true do
      //   if (cur.pos._1 == x2) and (cur.pos._2 == y2) then
      //     return
      //   end
      //   match cur.parent
      //   | let s: PathStep =>
      //     cur = s
      //   else
      //     break
      //   end
      // end
      try if _vis(idx2)? then return end end

      let cur_height = try _map(idx1)? else 100 end
      let dest_height = try _map(idx2)? else -100 end
      if (dest_height >= cur_height) and ((dest_height - cur_height) <= 1) then
        try _vis(idx2)? = true end
        _queue.push(PathStep(parent, dest, parent.length + 1))
      end
    end

  fun distance(a: (ISize, ISize), b: (ISize, ISize)): ISize =>
    ISize.from[USize]((b._1 - a._1).abs() + (b._2 - a._2).abs())
