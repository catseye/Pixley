/*
 * A PixleyController should implement the semantics of Pixley, but doesn't yet.
 */

/*
 * requires yoob.Controller
 * requires yoob.SexpParser
 */

var evalList = function(sexp, env) {
    args = [];
    while (sexp !== null) {
        if (!sexp instanceof yoob.Cons) {
            alert('assertion failed: not a yoob.Cons');
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
    } else if (ast instanceof yoob.Cons) {
        var head = ast.head;
        var fn;
        if (head instanceof yoob.Atom) {
            if (head.text === 'quote') {
                return ast.tail.head;
            } else if (head.text === 'car') {
                return evalPixley(ast.tail.head).head;
            } else if (head.text === 'cdr') {
                return evalPixley(ast.tail.head).tail;
            } else if (head.text === 'cons') {
                var a = evalPixley(ast.tail.head);
                var b = evalPixley(ast.tail.tail.head);
                return new yoob.Cons(a, b);
            } else {
                fn = evalPixley(ast.head, env);
            }
        } else {
            fn = evalPixley(ast.head, env);
        }
        args = evalList(ast.tail, env);
        return fn(args);
    } else if (ast instanceof yoob.Atom) {
        if (env[ast.text] === undefined) {
            alert('Unbound identifier: ' + ast.text);
        }
        return env[ast.text];
    } else {
        alert('wait what, not a yoob.Cons or yoob.Atom: ' + depict(ast));
    }
};

function PixleyController() {
    var intervalId;
    var finished;

    this.init = function(c) {
        this.ast = undefined;
        finished = false;
    };

    this.draw = function() {
        var display = document.getElementById('display');
        display.innerHTML = depict(this.ast);
    };

    this.step = function() {
        if (finished) return;
        result = evalPixley(this.ast, {});
        alert(depict(result));
        finished = true;
        this.draw();
    };

    this.load = function(text) {
        var p = new yoob.SexpParser();
        p.init(text);
        this.ast = p.parse();
        if (this.ast) {
            // alert(this.ast.toString());
            finished = false;
        } else {
            alert("Can't parse your Pixley program");
            finished = true;
        }
        this.draw();
    };
};
PixleyController.prototype = new yoob.Controller();
