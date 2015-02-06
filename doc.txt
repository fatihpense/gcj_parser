"A"
"B C D"
B.lines[
	"E F G" G.times["Z"]
	F.lines[]
]


---EXAMPLE USAGE---

name.A n
name.B w C w D n

B.times [
name.E w name.F w name.G G.times[ name.Z wn]
]

---PARSER TOKENS---
name, times, space_delimiter, newline_delimiter , s_or_n_delimiter , times_start , times_end

---PARSER NODES---
Node{
type:
value:
times:
children:
}
---DESIRED RESULT---
//maps and lists
{
"A":
"B":
"B.times":[ { 	"E":...,
				"F":...,
				"G":...,
				"G.times":[{"Z":...},{},{}...],
   } , {} ,{}..]
   
}