/*
 * A PixleyController should implement the semantics of Pixley, but doesn't yet.
 */

/*
 * requires yoob.Controller
 * requires yoob.SexpParser
 */

var depict = function(sexp) {
    var s = '';
    if (sexp instanceof yoob.Tree) {
        if (sexp.type === 'list') {
            s += '(';
            var len = sexp.children.length;
            for (var i = 0; i < len; i++) {
                s += depict(sexp.children[i]);
                if (i < (len - 1)) s += ' ';
            }
            s += ')';
            return s;
        } else if (sexp.type === 'atom') {
            return sexp.value;
        } else {
            alert('wait what');
        }
    } else {
        return '???' + sexp.toString();
    }
};

var pixleyCar = function(sexp) {
    return sexp.children[0];
};

var pixleyCdr = function(sexp) {
    return sexp.children[0];
};

var pixleyCons = function(sexp) {
    return new yoob.Tree('list', [sexp, sexp]);
};

var evalPixley = function(ast, env) {
    if (ast instanceof yoob.Tree) {
        if (ast.type === 'list') {
            if (ast.children.length == 0) {
                return ast;
            }
            var head = evalPixley(ast.children[0], env);
            var tail = ast.children[1];
            return head(tail, env);
        } else if (ast.type === 'atom') {
            return env[ast.value];
        } else {
            alert('wait what');
        }
    } else {
        alert('wait what, not a yoob.Tree');
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
        var c = ''
        if (this.ast) {
            c = depict(this.ast);
        }
        display.innerHTML = c;
    };

    this.step = function() {
        if (finished) return;
        var env = {
            'car': pixleyCar,
            'cdr': pixleyCdr,
            'cons': pixleyCons
        };
        result = evalPixley(this.ast, env);
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
