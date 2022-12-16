use "collections"
use "files"
use "math"

primitive Old
primitive New
type Operand is (Old | New | U128)

primitive Plus
primitive Times
type Operator is (Plus | Times)

class Monkey
  let index: USize
  let items: Array[U128]
  let oper: Operator
  let lhs: Operand
  let rhs: Operand
  let div: U128
  let dest_true: USize
  let dest_false: USize
  var inspected: U128 = 0

  new create(
    index': USize,
    items': Array[U128],
    oper': Operator,
    lhs': Operand,
    rhs': Operand,
    div': U128,
    dest_true': USize,
    dest_false': USize)
  =>
    index = index'
    items = items'
    oper = oper'
    lhs = lhs'
    rhs = rhs'
    div = div'
    dest_true = dest_true'
    dest_false = dest_false'

  fun string(): String iso^ =>
    let s: String iso = String
    s.append("Monkey " + index.string() + ": [")
    for item in items.values() do
      s.append(" " + item.string())
    end
    s.append(" ]; new = ")
    match lhs
    | New => s.append("new")
    | Old => s.append("old")
    | let n: U128 => s.append(n.string())
    end
    s.append(" ")
    match oper
    | Plus => s.append("+")
    | Times => s.append("*")
    end
    s.append(" ")
    match rhs
    | New => s.append("new")
    | Old => s.append("old")
    | let n: U128 => s.append(n.string())
    end
    s.append("; divby " + div.string() + " ? " + dest_true.string() + " : " + dest_false.string())
    consume s

actor Main
  new create(env: Env) =>
    process_monkeys(env, 1, true, 20) // 50172
    process_monkeys(env, 2, false, 10000) // 11614682178

  fun process_monkeys(env: Env, part: USize, div3: Bool, iterations: USize) =>
    let file = File(FilePath(FileAuth(env.root), "input.txt"))

    let monkeys = get_monkeys(file)

    for i in Range(0, iterations) do
      if (i > 0) and ((i == 1) or (i == 20) or ((i % 1000) == 0)) then
        env.out.print("== After round " + i.string() + " ==")
        for monkey in monkeys.values() do
          env.out.print("Monkey " + monkey.index.string() + " inspected items " + monkey.inspected.string() + " times.")
        end
        env.out.print("")
      end

      var lcm: U128 = 1
      for monkey in monkeys.values() do
        lcm = lcm * monkey.div
      end

      for monkey in monkeys.values() do
        for item in monkey.items.values() do
          monkey.inspected = monkey.inspected + 1

          let rhs =
            match monkey.rhs
            | Old => item
            | let n: U128 => n
            else 0
            end

          var result =
            try
              match monkey.oper
              | Times => item *? rhs
              | Plus => item +? rhs
              end
            else
              env.out.print("overflow at iteration " + i.string() + ", monkey " + monkey.index.string())
              return
            end

          if div3 then
            result = result / 3
          else
            result = result % lcm
          end

          try
            if (result % monkey.div) == 0 then
              monkeys(monkey.dest_true)?.items.push(result)
            else
              monkeys(monkey.dest_false)?.items.push(result)
            end
          end
        end
        monkey.items.clear()
      end
    end

    let inspections = MaxHeap[U128](monkeys.size())
    for monkey in monkeys.values() do
      inspections.push(monkey.inspected)
    end
    try
      let total = inspections.pop()? * inspections.pop()?
      env.out.print("part" + part.string() + ": " + total.string())
    end

  fun get_monkeys(file: File): Array[Monkey] =>
    let monkeys = Array[Monkey]

    let items = Array[U128]
    var oper: Operator = Times
    var lhs: Operand = Old
    var rhs: Operand = Old
    var div: U128 = 1
    var dest_true: USize = 0
    var dest_false: USize = 0

    for line' in FileLines(file) do
      let line: String val = consume line'

      if line.trim(0, 6) == "Monkey" then
        items.clear()
      elseif line.trim(2, 6) == "Star" then
        var i: USize = 18
        while i < line.size() do
          (let num, let next) = parse_number(line, i)
          items.push(U128.from[ISize](num))
          i = next + 2
        end
      elseif line.trim(2, 6) == "Oper" then
        var i: USize = 19
        (lhs, let next) = parse_operand(line, i)
        try
          oper = if line(next + 1)? == '*' then Times else Plus end
        end
        (rhs, _) = parse_operand(line, next + 3)
      elseif line.trim(2, 6) == "Test" then
        (let n, _) = parse_number(line, 21)
        div = U128.from[ISize](n)
      elseif line.trim(7, 11) == "true" then
        dest_true = USize.from[ISize](parse_number(line, line.size() - 1)._1)
      elseif line.trim(7, 12) == "false" then
        dest_false = USize.from[ISize](parse_number(line, line.size() - 1)._1)

        var monkey = Monkey(monkeys.size(), items.clone(), oper, lhs, rhs, div, dest_true, dest_false)
        monkeys.push(monkey)
      end
    end
    monkeys

  fun parse_operand(line: String, i: USize): (Operand, USize) =>
    if line.trim(i, i + 3) == "old" then
      (Old, i + 3)
    elseif line.trim(i, i + 3) == "new" then
      (New, i + 3)
    else
      (let n, let next) = parse_number(line, i)
      (U128.from[ISize](n), next)
    end

  fun parse_number(line: String, i: USize): (ISize, USize) =>
    try
      var next: USize = i
      while true do
        if (next == line.size()) or
            (not (
              (line(next)? == '-') or
              (line(next)? == '+') or
              ((line(next)? >= '0') and (line(next)? <= '9')
            ))
          )
        then
          return (line.trim(i, next).isize()?, next)
        end
        next = next + 1
      end
    end
    (0, 0)
