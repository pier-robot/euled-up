Need OpenImageIO and numpy


Red means go here.
Green means X has played here already.
Blue means O has played here already.
Blank is blank.

`python generate.py` writes to csv files where the first column is the node id,
the next is the index of the cell to move in (or being moved to),
followed by 9 child node ids.
Nodes are in reverse topological order. Therefore leaf nodes are printed first
and the children of a node will appear in the file before said node.
