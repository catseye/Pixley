/*
 * requires yoob.Controller and pixley.js
 */
errorHandler.error = function(msg) {
    alert('ERROR! ' + msg);
};

function PixleyController() {
    this.init = function(cfg) {
        this.ast = undefined;
        this.status = cfg.status;
        this.pixleyInterpreter = cfg.pixleyInterpreter || '???';
        this.display = cfg.display;
        this.output = cfg.output;
        this.finished = false;
        this.setStatus('Ready.');
    };

    this.setStatus = function(text) {
        if (this.status) {
            this.status.innerHTML = text;
        }
    };

    this.draw = function() {
        var display = document.getElementById('display');
        display.innerHTML = depict(this.ast);
        if (this.depictor) {
            this.depictor.depict(this.ast);
        }
    };

    this.step = function() {
        if (this.finished) return;
        this.setStatus('Evaluating...');
        var result = evalPixley(this.ast, {});
        this.output.innerHTML = depict(result);
        this.finished = true;
        this.setStatus('Done.');
        this.draw();
    };

    this.load = function(text) {
        var p = new SexpParser();
        p.init(text);
        this.ast = p.parse();
        if (this.ast) {
            this.finished = false;
            this.setStatus('Program loaded.');
        } else {
            errorHandler.error("Can't parse your Pixley program");
            this.finished = true;
            this.setStatus('Parsing error!');
        }
        this.output.innerHTML = '';
        this.draw();
    };

    this.wrapIt = function() {
        var text = '(' + this.pixleyInterpreter +
                   ' (quote ' + depict(this.ast) + '))';
        this.load(text);
    };
};
PixleyController.prototype = new yoob.Controller();
