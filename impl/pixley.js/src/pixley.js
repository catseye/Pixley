/*
 * A PixleyController should implement the semantics of Pixley, but doesn't yet.
 */

/*
 * requires yoob.Controller
 * requires yoob.SexpParser
 */

function PixleyController() {
    var intervalId;
    var program;

    this.init = function(c) {
        this.load("");
    };

    this.draw = function() {
        ;
    };

    this.step = function() {
        this.draw();
    };

    this.load = function(text) {
        program = text;
        this.draw();
    };
};
PixleyController.prototype = new yoob.Controller();
