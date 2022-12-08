use "collections"
use "files"

actor Main
  let _env: Env

  new create(env: Env) =>
    _env = env

    let file = File(FilePath(FileAuth(env.root), "input.txt"))

    var width: USize = 0

    let trees = Array[Array[U8]]
    for line' in FileLines(file) do
      let line: String val = consume line'
      let row = Array[U8]
      for ch in line.values() do
        row.push(ch - '0')
      end
      if row.size() > width then
        width = row.size()
      end

      trees.push(row)
    end

    var num_visible: USize = 0
    var best_dist: USize = 0
    for r in Range(1, trees.size()-1) do
      for c in Range(1, width-1) do
        (let vis, let dist) = is_visible(r, c, trees)
        if dist > best_dist then
          best_dist = dist
        end
        if vis then
          num_visible = num_visible + 1
        end
      end
    end

    let on_edges = (trees.size() * 2) + ((width - 2) * 2)

    env.out.print("part1: " + (num_visible + on_edges).string()) // 1676
    env.out.print("part2: " + best_dist.string()) // 313200

  fun is_visible(row: USize, col: USize, trees: Array[Array[U8]]): (Bool, USize) =>
    var up = true
    var down = true
    var left = true
    var right = true

    var up_dist: USize = 0
    var down_dist: USize = 0
    var left_dist: USize = 0
    var right_dist: USize = 0

    try
      let height = trees(row)?(col)?

      // up
      for y in Reverse(row-1, 0) do
        up_dist = row - y
        if trees(y)?(col)? >= height then
          up = false
          break
        end
      end
      // down
      for y in Range(row+1, trees.size()) do
        down_dist = y - row
        if trees(y)?(col)? >= height then
          down = false
          break
        end
      end
      // left
      for x in Reverse(col-1, 0) do
        left_dist = col - x
        if trees(row)?(x)? >= height then
          left = false
          break
        end
      end
      // right
      for x in Range(col+1, trees(row)?.size()) do
        right_dist = x - col
        if trees(row)?(x)? >= height then
          right = false
          break
        end
      end
    end

    (up or down or left or right, up_dist * down_dist * left_dist * right_dist)
