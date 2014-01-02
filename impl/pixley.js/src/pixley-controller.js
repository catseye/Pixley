/*
 * requires yoob.Controller and pixley.js
 */
function PixleyController() {
    var finished;
    var status = document.getElementById('status');

    this.init = function(c) {
        this.ast = undefined;
        finished = false;
        status.innerHTML = 'Ready.';
    };

    this.draw = function() {
        var display = document.getElementById('display');
        display.innerHTML = depict(this.ast);
    };

    this.step = function() {
        if (finished) return;
        status.innerHTML = 'Evaluating...';
        var result = evalPixley(this.ast, {});
        alert(depict(result));
        finished = true;
        status.innerHTML = 'Done.';
        this.draw();
    };

    this.load = function(text) {
        var p = new SexpParser();
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

    this.wrapIt = function() {
        var pixley = document.getElementById('pixley-interpreter').innerHTML;
        var text = '(' + pixley + ' (quote ' + depict(this.ast) + '))';
        this.load(text);
    };
};
PixleyController.prototype = new yoob.Controller();

errorHandler.error = function(msg) {
    alert('ERROR! ' + msg);
}
