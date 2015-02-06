# Google Code Jam input parser in Dart

For example, take input file of [this problem](https://code.google.com/codejam/contest/438101/dashboard#s=p2).

"The first line of the input gives the number of test cases, T. T lines follow. Each will consist only of space-separated integers: first P, then C, then P integers S0...SP-1."

###Sample rulestring for input:
```
name.T n
T.times [ name.P s name.C s P.times [ name.S sn ] ]
```

###Sample code with rule string:
```
import "dart:io";
import "package:gcj_parser/gcj_parser.dart";

void main() {
  print("Hello, World!");

  String content = new File("C-small-practice.in").readAsStringSync();

  String rulestring = """
name.T n
T.times [ name.P s name.C s P.times [ name.S sn ] ]
""";

  Map m;
  try {
    m = parseToMap(rulestring, content);
    print("Map: $m");
  } catch (e) {
    print(e);
  }

}
```


###Sutput map(prettified):
```
{  
   T:100,
   T.times:[  
      {  
         P:2,
         C:2,
         P.times:[  
            {  
               S:73
            },
            {  
               S:100
            }
         ]
      },
      {  
         P:3,
         C:2,
         P.times:[  
            {  
               S:245
            },
            {  
               S:272
            },
            {  
               S:238
            }
         ]
      },
      {  
         P:5,
         C:1,
         P.times:[  
            {  
               S:2
            },
            {  
               S:7
            },
            {  
               S:10
            },
            {  
               S:5
            },
            {  
               S:4
            }
         ]
      },
      {  
         P:1,
         C:1,
         P.times:[  
            {  
               S:10
            }
         ]
      },
      {  
         P:6,
         C:1,
         P.times:[  
            {  
               S:0
            },
            {  
               S:9
            },
            {  
               S:1
            },
            {  
               S:6
            },
            {  
               S:3
            },
            {  
               S:3
            }
         ]
      },
    // other cases till 100th case...
}

```