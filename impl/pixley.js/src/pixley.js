/*
 * A PixleyController should implement the semantics of Pixley, but doesn't yet.
 */

/*
 * requires yoob.Controller
 * requires yoob.SexpParser
 */

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
            c = this.ast.toString();
        }
        display.innerHTML = c;
    };

    this.step = function() {
        if (finished) return;
        result = this.evalPixley(this.ast);
        alert(result.toString());
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
    
    this.evalPixley = function(ast) {
        if (ast instanceof yoob.Tree) {
            if (ast.type === 'list') {
                return ast;
            } else if (ast.type === 'atom') {
                return ast.value;
            } else {
                alert('wait what');
            }
        } else {
            alert('wait what, not a yoob.Tree');
        }
    };
};
PixleyController.prototype = new yoob.Controller();
