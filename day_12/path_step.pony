class PathStep
  let parent: (PathStep | None)
  let pos: (ISize, ISize)
  let length: ISize

  new create(parent': (PathStep | None), pos': (ISize, ISize), length': ISize) =>
    parent = parent'
    pos = pos'
    length = length'
