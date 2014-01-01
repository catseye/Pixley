/*
 * This file is part of yoob.js version 0.3
 * Available from https://github.com/catseye/yoob.js/
 * This file is in the public domain.  See http://unlicense.org/ for details.
 */
if (window.yoob === undefined) yoob = {};

/*
 * A simple S-expression parser.
 * WHOA, MODIFIED FROM THE yoob.js STOCK VERSION, A LOT
 *
 * requires you load yoob.Tree and yoob.Scanner first
 */
var depict = function(sexp) {
    var s = '';
    if (sexp instanceof yoob.Cons) {
        s += '(';
        s += depict(sexp.head);
        while (sexp.tail instanceof yoob.Cons) {
            s += ' ';
            s += depict(sexp.tail.head);
            sexp = sexp.tail;
        }
        s += ')';
        return s;
    } else if (sexp instanceof yoob.Atom) {
        return sexp.text;
    } else if (sexp === undefined) {
        return 'undefined';
    } else if (sexp === null) {
        return '()';
    } else {
        return '???' + sexp.toString();
    }
};

yoob.Atom = function(text) {
  this.text = text;
  
  this.toString = function() {
    return this.text;
  }
};

yoob.Cons = function(head, tail) {
  this.head = head;
  this.tail = tail;

  this.toString = function() {
    return depict(this);
  }
};

yoob.SexpParser = function() {
  this.scanner = undefined;

  this.init = function(text) {
    this.scanner = new yoob.Scanner();
    this.scanner.init([
      ['paren',  "^(\\(|\\))"],
      ['atom',   "^([a-zA-Z\\?][a-zA-Z0-9\\?]*)"]
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
      return new yoob.Atom(x);
    } else if (this.scanner.consume('(')) {
      if (this.scanner.consume(')') || this.scanner.onType('EOF')) {
        return null;
      }
      
      var top = new yoob.Cons(null, null);
      top.head = this.parse();
      var cell = top;
      while (!this.scanner.consume(')') && !this.scanner.onType('EOF')) {
        cell.tail = new yoob.Cons(null, null);
        cell = cell.tail;
        cell.head = this.parse();
      }
      return top;
    } else {
      /* register some kind of error */
      this.scanner.scan();
    }
  };

};
