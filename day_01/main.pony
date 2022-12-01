use "collections"
use "files"

actor Main
  let elf_totals: Array[USize] = Array[USize]
  var cur_total: USize = 0
  var max_total: USize = 0

  new create(env: Env) =>
    let file = File(FilePath(FileAuth(env.root), "input.txt"))

    for line in FileLines(file) do
      if line.size() == 0 then
        finish_elf()
      else
        try
          cur_total = cur_total + line.usize()?
        end
      end
    end

    finish_elf()

    env.out.print("max elf total = " + max_total.string()) // 68427

    let sorted_totals = Sort[Array[USize], USize](elf_totals)
    try
      let len = sorted_totals.size()
      let top_three_total =
        sorted_totals(len - 1)? +
        sorted_totals(len - 2)? +
        sorted_totals(len - 3)?

      env.out.print("top three total = " + top_three_total.string()) // 203420
    else
      env.err.print("Unable to get top 3")
    end

  fun ref finish_elf() =>
    if cur_total > 0 then
      if cur_total > max_total then
        max_total = cur_total
      end

      elf_totals.push(cur_total)
      cur_total = 0
    end
