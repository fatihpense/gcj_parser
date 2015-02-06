library gcj_parser;



void _test() {
  String rules = """
name.A n 
   A.times [ name.B s name.C n 

 ]
""";
  String content = """
2
100 200
1000 2000
""";
  //test();
  try {
    parseToMap(rules, content);
  } catch (e) {
    print(e);
  }
}



const _tt_name = "name";
const _tt_times = "times";
const _tt_space_delimiter = "space_delimiter";
const _tt_newline_delimiter = "newline_delimiter";
const _tt_sn_delimiter = "sn_delimiter";
const _tt_times_start = "times_start";
const _tt_times_end = "times_end";

class Token {
  String Type; // _tt_ name , times, space_delimiter , newline_delimiter..
  String Value;
}

const _nt_root = "root";
const _nt_value = "value";
const _nt_times = "times";


//parse tree node
class Node {
  String Type; // _nt_ root , value, times
  String Name; //for times,value
  String Value; //for times
  String Delimiter; // s n sn
  Node Parent;
  List<Node> Chidren; //for root, times
}


Node _parseRuleString(String rulestring) {

  //convert to tokens
  List<Token> token_list = new List<Token>();

  List<String> tokens_raw = rulestring.trim().split(new RegExp(r'\s+'));
  for (String r in tokens_raw) {
    token_list.add(_detectToken(r));
  }


  //produce parsetree from tokens
  Node root_node = _compileToTree(token_list, null);
  return root_node;
}

//parse input file and produce map according to parsing rule tree
String _parseInputString(Node parseRuleNode, Map resultMap, String inputstring)
    {

  if (parseRuleNode.Type == _nt_root) {
    for (Node n in parseRuleNode.Chidren) {
      inputstring = _parseInputString(n, resultMap, inputstring);
    }
  }

  if (parseRuleNode.Type == _nt_value) {

    int del_index = 0;
    if (parseRuleNode.Delimiter == _tt_newline_delimiter) {
      del_index = inputstring.indexOf("\n");
    }
    if (parseRuleNode.Delimiter == _tt_space_delimiter) {
      del_index = inputstring.indexOf(" ");
    }
    if (parseRuleNode.Delimiter == _tt_sn_delimiter) {
      del_index = inputstring.indexOf(new RegExp(r'\s+'));
    }


    resultMap[parseRuleNode.Name] = inputstring.substring(0, del_index).trim();
    inputstring = inputstring.substring(del_index).trimLeft();

  }

  if (parseRuleNode.Type == _nt_times) {
    List<Map> times_map_list = new List<Map>();
    int times = int.parse(resultMap[parseRuleNode.Value] as String);
    for (int i = 0; i < times; i++) {
      //create new map for each turn and populate it
      Map m = new Map();
      for (Node n in parseRuleNode.Chidren) {
        inputstring = _parseInputString(n, m, inputstring);
      }
      times_map_list.add(m);
    }
    resultMap[parseRuleNode.Name] = times_map_list;
  }

  return inputstring;
}

Map parseToMap(String rulestring, String content) {
  Map resultMap = new Map();
  _parseInputString(_parseRuleString(rulestring), resultMap, content);
  return resultMap;
}

Token _detectToken(String input) {
  Token t = new Token();
  if (input.startsWith("name.")) {
    t.Type = _tt_name;
    t.Value = input.split(".")[1];
  } else if (input.endsWith(".times")) {
    t.Type = _tt_times;
    t.Value = input.split(".")[0];
  } else if (input == "[") {
    t.Type = _tt_times_start;
  } else if (input == "]") {
    t.Type = _tt_times_end;
  } else if (input == "s") {
    t.Type = _tt_space_delimiter;
  } else if (input == "n") {
    t.Type = _tt_newline_delimiter;
  } else if (input == "sn") {
    t.Type = _tt_sn_delimiter;
  } else {
    throw new StateError("unidentified token:" + input);
  }
  return t;
}

Node _compileToTree(List<Token> token_list, Node parent) {
  //create root if not exists
  if (parent == null) {
    Node root_node = new Node();
    root_node.Type = _nt_root;
    root_node.Chidren = new List<Node>();
    _compileToTree(token_list, root_node);
    return root_node;
  }

  if (token_list.length == 0) {
    return parent;
  }

  Token t = token_list.removeAt(0);
  //value? must have a delimiter afterwards
  if (t.Type == _tt_name) {
    Node n = new Node();
    n.Parent = parent;
    n.Type = _nt_value;
    n.Name = t.Value;
    Token del = token_list.removeAt(0);
    if (del.Type == _tt_space_delimiter ||
        del.Type == _tt_newline_delimiter ||
        del.Type == _tt_sn_delimiter) {
      n.Delimiter = del.Type;
    } else {
      throw new StateError("expected delimiter after name." + n.Name);
    }

    parent.Chidren.add(n);
    _compileToTree(token_list, parent);

    return parent; //it can be null, even
  }
  //times? must have start afterwards
  if (t.Type == _tt_times) {
    Node n = new Node();
    n.Type = _nt_times;
    n.Parent = parent;
    n.Name = t.Value + ".times";
    n.Value = t.Value;
    n.Chidren = new List<Node>();
    Token times_start = token_list.removeAt(0);
    if (times_start.Type == _tt_times_start) {
      //noproblem
    } else {
      throw new StateError("expected [ after " + n.Name);
    }

    parent.Chidren.add(n);
    _compileToTree(token_list, n);
    return parent;
  }
  //if there is times_end start filling parent
  if (t.Type == _tt_times_end) {
    if (parent.Type == _nt_root) {
      throw new StateError("please check for extra ] .");
    }
    _compileToTree(token_list, parent.Parent);
    return parent.Parent;
  }

  return parent;
}
