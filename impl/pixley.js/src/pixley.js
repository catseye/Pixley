/*
 * A PixleyController should implement the semantics of Pixley, but doesn't yet.
 */

/*
 * requires yoob.Controller
 * requires yoob.SexpParser
 */

function PixleyController() {
    var intervalId;

    this.init = function(c) {
        this.ast = undefined;
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
        this.draw();
    };

    this.load = function(text) {
        var p = new yoob.SexpParser();
        p.init(text);
        this.ast = p.parse();
        if (this.ast) {
            // alert(this.ast.toString());
        } else {
            alert("Can't parse your Pixley program");
        }
        this.draw();
    };
};
PixleyController.prototype = new yoob.Controller();
