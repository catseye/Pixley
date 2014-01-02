/*
 * The functions and object in this file implement the semantics of Pixley.
 * (almost.)
 */

/*
 * Our lexical scanner.  This is a straight copy of the yoob.Scanner object
 * from yoob.js 0.3, pasted in here for convenience.
 */
var Scanner = function() {
  this.text = undefined;
  this.token = undefined;
  this.type = undefined;
  this.error = undefined;
  this.table = undefined;
  this.whitespacePattern = "^[ \\t\\n\\r]*";

  this.init = function(table) {
    this.table = table;
  };

  this.reset = function(text) {
    this.text = text;
    this.token = undefined;
    this.type = undefined;
    this.error = undefined;
    this.scan();
  };
  
  this.scanPattern = function(pattern, type) {
    var re = new RegExp(pattern);
    var match = re.exec(this.text);
    if (match === null) return false;
    this.type = type;
    this.token = match[1];
    this.text = this.text.substr(match[0].length);
    return true;
  };

  this.scan = function() {
    this.scanPattern(this.whitespacePattern, "whitespace");
    if (this.text.length === 0) {
      this.token = null;
      this.type = "EOF";
      return;
    }
    for (var i = 0; i < this.table.length; i++) {
      var type = this.table[i][0];
      var pattern = this.table[i][1];
      if (this.scanPattern(pattern, type)) return;
    }
    if (this.scanPattern("^([\\s\\S])", "unknown character")) return;
    // should never get here
  };

  this.expect = function(token) {
    if (this.token === token) {
      this.scan();
    } else {
      this.error = "expected '" + token + "' but found '" + this.token + "'";
    }
  };

  this.on = function(token) {
    return this.token === token;
  };

  this.onType = function(type) {
    return this.type === type;
  };

  this.checkType = function(type) {
    if (this.type !== type) {
      this.error = "expected " + type + " but found " + this.type + " (" + this.token + ")"
    }
  };

  this.expectType = function(type) {
    this.checkType(type);
    this.scan();
  };

  this.consume = function(token) {
    if (this.on(token)) {
      this.scan();
      return true;
    } else {
      return false;
    }
  };
};

/*
 * S-expressions, apropos to Pixley.
 */
var Atom = function(text) {
  this.text = text;
  
  this.toString = function() {
    return this.text;
  }
};

var Cons = function(head, tail) {
  this.head = head;
  this.tail = tail;

  this.toString = function() {
    return depict(this);
  }
};

var depict = function(sexp) {
    var s = '';
    if (sexp instanceof Cons) {
        s += '(';
        s += depict(sexp.head);
        while (sexp.tail instanceof Cons) {
            s += ' ';
            s += depict(sexp.tail.head);
            sexp = sexp.tail;
        }
        s += ')';
        return s;
    } else if (sexp instanceof Atom) {
        return sexp.text;
    } else if (sexp === undefined) {
        return 'undefined';
    } else if (sexp === null) {
        return '()';
    } else {
        return '???' + sexp.toString();
    }
};

/*
 * A simple S-expression parser, mostly a copy of yoob.js 0.3's
 * yoob.SexpParser, but modified to work with our S-expressions
 * instead of yoob.Trees.
 */
var SexpParser = function() {
  this.scanner = undefined;

  this.init = function(text) {
    this.scanner = new Scanner();
    this.scanner.init([
      ['paren',  "^(\\(|\\))"],
      ['atom',   "^([a-zA-Z\\?\\*][a-zA-Z0-9\\?\\*]*)"]
    ]);
    this.scanner.reset(text);
  };

  /*
   * SExp ::= Atom | "(" {SExpr} ")".
   */
  this.parse = function(text) {
    if (this.scanner.onType('atom')) {
      var x = this.scanner.token;
      this.scanner.scan();
      return new Atom(x);
    } else if (this.scanner.consume('(')) {
      if (this.scanner.consume(')') || this.scanner.onType('EOF')) {
        return null;
      }
      
      var top = new Cons(null, null);
      top.head = this.parse();
      var cell = top;
      while (!this.scanner.consume(')') && !this.scanner.onType('EOF')) {
        cell.tail = new Cons(null, null);
        cell = cell.tail;
        cell.head = this.parse();
      }
      return top;
    } else {
      /* TODO: register some kind of error */
      this.scanner.scan();
    }
  };
};

/********************
 * Pixley Semantics *
 ********************/

var listP = function(sexp) {
    if (sexp === null) return true;
    if (!(sexp instanceof Cons)) return false;
    return listP(sexp.tail);
};

var equalP = function(a, b) {
    if (a === null && b == null) return true;
    if (a instanceof Atom && b instanceof Atom && a.text === b.text) {
        return true;
    }
    if (a instanceof Cons && b instanceof Cons) {
        return equalP(a.head, b.head) && equalP(a.tail, b.tail);
    }
    return false;
};

var bind = function(identifier, value, env) {
    // alert('let ' + depict(identifier) + ' = ' + depict(value));
    var newEnv = {};
    for (var key in env) {
        newEnv[key] = env[key];
    }
    newEnv[identifier] = value;
    return newEnv;
};

var bindAll = function(bindings, env) {
    while (bindings !== null) {
        binding = bindings.head;
        value = evalPixley(binding.tail.head, env);
        env = bind(binding.head, value, env);
        bindings = bindings.tail;
    }
    return env;
};

var evalList = function(sexp, env) {
    args = [];
    while (sexp !== null) {
        if (!sexp instanceof Cons) {
            alert('assertion failed: not a Cons');
            return [];
        }
        args.push(evalPixley(sexp.head, env));
        sexp = sexp.tail;
    }
    return args;
};

var evalPixley = function(ast, env) {
    if (ast === null) {
        return null;
    } else if (ast instanceof Cons) {
        var head = ast.head;
        var fn;
        if (head instanceof Atom) {
            if (head.text === 'quote') {
                return ast.tail.head;
            } else if (head.text === 'car') {
                return evalPixley(ast.tail.head, env).head;
            } else if (head.text === 'cdr') {
                return evalPixley(ast.tail.head, env).tail;
            } else if (head.text === 'cons') {
                var a = evalPixley(ast.tail.head, env);
                var b = evalPixley(ast.tail.tail.head, env);
                return new Cons(a, b);
            } else if (head.text === 'list?') {
                var a = evalPixley(ast.tail.head, env);
                return new Atom(listP(a) ? '#t' : '#f');
            } else if (head.text === 'equal?') {
                var a = evalPixley(ast.tail.head, env);
                var b = evalPixley(ast.tail.tail.head, env);
                return new Atom(equalP(a, b) ? '#t' : '#f');
            } else if (head.text === 'let*') {
                var bindings = ast.tail.head;
                var body = ast.tail.tail.head;
                var newEnv = bindAll(bindings, env);
                return evalPixley(body, newEnv);
            } else if (head.text === 'cond') {
                var branch = ast.tail;
                while (branch !== null) {
                    var b = branch.head;
                    var test = b.head;
                    if (test instanceof Atom &&
                        test.text === 'else') {
                        return evalPixley(b.tail.head, env);
                    } else {
                        var result = evalPixley(test, env);
                        if (result instanceof Atom &&
                            result.text === '#t') {
                            return evalPixley(b.tail.head, env);
                        }
                        branch = branch.tail;
                    }
                }
                alert('no else in cond');
                return head;
            } else if (head.text === 'lambda') {
                alert('not implemented');
                return head;
            } else {
                fn = evalPixley(ast.head, env);
            }
        } else {
            fn = evalPixley(ast.head, env);
        }
        args = evalList(ast.tail, env);
        return fn(args);
    } else if (ast instanceof Atom) {
        if (env[ast.text] === undefined) {
            alert('Unbound identifier: ' + ast.text);
        }
        return env[ast.text];
    } else {
        alert('wait what, not a Cons or Atom: ' + depict(ast));
    }
};

var runPixley = function(text) {
    var p = new SexpParser();
    p.init(text);
    var ast = p.parse();
    if (ast) {
        return evalPixley(ast, {});
    } else {
        return undefined;
    }
};
