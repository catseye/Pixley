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
        this.display = cfg.display;
        this.output = cfg.output;
        this.workerURL = cfg.workerURL || "../src/pixley-worker.js";
        this.loadWorker();
        this.running = false;
        this.setStatus('Ready.');
    };

    this.loadWorker = function() {
        if (!this.worker) {
            this.worker = new Worker(this.workerURL);
        }
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
        if (this.running) return;
        this.setStatus('Evaluating...');

        this.loadWorker();
        var $this = this;
        this.worker.addEventListener('message', function(e) {
            $this.output.innerHTML = e.data;
            $this.setStatus('Done.');
            $this.running = false;
            $this.draw();
        });
        this.worker.postMessage(["eval", depict(this.ast)]);
        this.running = true;
    };

    this.stop = function() {
        if (this.running && this.worker) {
            this.worker.terminate();
            this.running = false;
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

    this.wrapWith = function(lambdaText) {
        this.load('(' + lambdaText + ' (quote ' + depict(this.ast) + '))');
    };
};
PixleyController.prototype = new yoob.Controller();
