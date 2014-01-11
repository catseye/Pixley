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
        this.workerURL = cfg.workerURL || "../src/pixley-worker.js";
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

    this.start = function() {
        this.setStatus('Evaluating...');

        this.worker = new Worker(this.workerURL);
        var $this = this;
        this.worker.addEventListener('message', function(e) {
            $this.output.innerHTML = e.data;
            $this.setStatus('Done.');
            $this.draw();
            $this.worker = undefined;
        });
        this.worker.postMessage(["eval", depict(this.ast)]);
    };

    this.stop = function() {
        if (this.worker) {
            this.worker.terminate();
            this.worker = undefined;
            this.setStatus('Terminated.');
        }
    };

    this.load = function(text) {
        var p = new SexpParser();
        p.init(text);
        this.ast = p.parse();
        if (this.ast) {
            this.setStatus('Program loaded.');
        } else {
            errorHandler.error("Can't parse your Pixley program");
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
