/*
 * requires yoob.Controller and pixley.js
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
};
PixleyController.prototype = new yoob.Controller();

errorHandler.error = function(msg) {
    alert('ERROR! ' + msg);
}
