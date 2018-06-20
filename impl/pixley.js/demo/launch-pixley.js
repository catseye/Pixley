function launch(prefix, container, config) {
  if (typeof container === 'string') {
    container = document.getElementById(container);
  }
  config = config || {};

  function loadThese(deps, callback) {
    var loaded = 0;
    for (var i = 0; i < deps.length; i++) {
      var elem = document.createElement('script');
      elem.src = prefix + deps[i];
      elem.onload = function() {
        if (++loaded < deps.length) return;
        callback();
      }
      document.body.appendChild(elem);
    }
  }

  loadThese([
    "src/pixley.js",
    "src/yoob/source-manager.js",
    "src/yoob/preset-manager.js",
    "src/yoob/element-factory.js",
    "src/pixley-controller.js",
    "src/pixley-depictor.js",
    "src/pixley-launcher.js",
    "demo/examples.js"
  ], function() {
    /* --- Make UI --- */

    var controlPanel = yoob.makeDiv(container);
    var startButton = yoob.makeButton(controlPanel, "Start");
    var stopButton = yoob.makeButton(controlPanel, "Stop");
    var wrapButton = yoob.makeButton(controlPanel, "Wrap in Pixley Interpreter");
    var editPanel = yoob.makeDiv(container);
    var selectPanel = yoob.makeDiv(container);
    var selectElem = yoob.makeSelect(selectPanel, "example source:", []);

    var rowFluid = yoob.makeDiv(container);
    rowFluid.className = "row-fluid";
    var column1 = yoob.makeDiv(rowFluid);
    column1.className = "span6";
    var animationPanel = yoob.makeDiv(column1);

    yoob.makeParagraph(animationPanel, "Status:");
    var status = yoob.makePre(animationPanel);
    status.id = "status";

    yoob.makeParagraph(animationPanel, "Result:");
    var output = yoob.makePre(animationPanel);

    yoob.makeParagraph(animationPanel, "Program:");
    var display = yoob.makePre(animationPanel);

    var column2 = yoob.makeDiv(rowFluid);
    column2.className = "span6";
    yoob.makeParagraph(column2, "Depiction:");
    var depictionCanvas = yoob.makeCanvas(column2);
    depictionCanvas.id = "canvas";

    var editor = yoob.makeTextArea(container);

    /* --- Make Controller --- */

    launchPixley({
        status: status,
        display: display,
        output: output,
        startButton: startButton,
        stopButton: stopButton,
        wrapButton: wrapButton,
        pixleyInterpreter: "(lambda (program)\n  (let* ((interpreter (lambda (interpret program env)\n    (let*  ((cadr (lambda (alist)\n              (car (cdr alist))))\n            (null? (lambda (expr)\n              (equal? expr (quote ()))))\n            (find (lambda (self elem alist)\n              (cond\n                ((null? alist)\n                  (quote nothing))\n                (else\n                  (let* ((entry (car alist))\n                         (key   (car entry))\n                         (rest  (cdr alist)))\n                    (cond\n                      ((equal? elem key)\n                        entry)\n                      (else\n                        (self self elem rest))))))))\n            (interpret-args (lambda (interpret-args args env)\n              (cond\n                ((null? args)\n                  args)\n                (else\n                  (let* ((arg  (car args))\n                         (rest (cdr args)))\n                    (cons (interpret interpret arg env) (interpret-args interpret-args rest env)))))))\n            (expand-args (lambda (expand-args formals argvals)\n              (cond\n                ((null? formals)\n                  formals)\n                (else\n                  (let* ((formal       (car formals))\n                         (rest-formals (cdr formals))\n                         (argval       (car argvals))\n                         (rest-argvals (cdr argvals)))\n                    (cons (cons formal (cons argval (quote ()))) (expand-args expand-args rest-formals rest-argvals)))))))\n            (concat-envs (lambda (concat-envs new-env old-env)\n              (cond\n                ((null? new-env)\n                  old-env)\n                (else\n                  (let* ((entry (car new-env))\n                         (rest  (cdr new-env)))\n                    (cons entry (concat-envs concat-envs rest old-env)))))))\n             (call-lambda (lambda (func args env)\n               (let* ((arg-vals (interpret-args interpret-args args env)))\n                  (func arg-vals)))))\n      (cond\n        ((null? program)\n          program)\n        ((list? program)\n          (let* ((tag   (car program))\n                 (args  (cdr program))\n                 (entry (find find tag env)))\n            (cond\n              ((list? entry)\n                (call-lambda (cadr entry) args env))\n              ((equal? tag (quote lambda))\n                (let* ((formals (car args))\n                       (body    (cadr args)))\n                  (lambda (arg-vals)\n                    (let* ((arg-env   (expand-args expand-args formals arg-vals))\n                           (new-env   (concat-envs concat-envs arg-env env)))\n                      (interpret interpret body new-env)))))\n              ((equal? tag (quote cond))\n                (cond\n                  ((null? args)\n                    args)\n                  (else\n                    (let* ((branch   (car args))\n                           (test     (car branch))\n                           (expr     (cadr branch)))\n                      (cond\n                        ((equal? test (quote else))\n                          (interpret interpret expr env))\n                        ((interpret interpret test env)\n                          (interpret interpret expr env))\n                        (else\n                          (let* ((branches (cdr args))\n                                 (newprog (cons (quote cond) branches)))\n                            (interpret interpret newprog env))))))))\n              ((equal? tag (quote let*))\n                (let* ((bindings (car args))\n                       (body     (cadr args)))\n                  (cond\n                    ((null? bindings)\n                      (interpret interpret body env))\n                    (else\n                      (let* ((binding  (car bindings))\n                             (rest     (cdr bindings))\n                             (ident    (car binding))\n                             (expr     (cadr binding))\n                             (value    (interpret interpret expr env))\n                             (new-bi   (cons ident (cons value (quote ()))))\n                             (new-env  (cons new-bi env))\n                             (newprog  (cons (quote let*) (cons rest (cons body (quote ()))))))\n                        (interpret interpret newprog new-env))))))\n              ((equal? tag (quote list?))\n                (list? (interpret interpret (car args) env)))\n              ((equal? tag (quote quote))\n                (car args))\n              ((equal? tag (quote car))\n                (car (interpret interpret (car args) env)))\n              ((equal? tag (quote cdr))\n                (cdr (interpret interpret (car args) env)))\n              ((equal? tag (quote cons))\n                (cons (interpret interpret (car args) env) (interpret interpret (cadr args) env)))\n              ((equal? tag (quote equal?))\n                (equal? (interpret interpret (car args) env) (interpret interpret (cadr args) env)))\n              ((null? tag)\n                tag)\n              ((list? tag)\n                (call-lambda (interpret interpret tag env) args env))\n              (else\n                (call-lambda tag args env)))))\n        (else\n          (let* ((entry (find find program env)))\n            (cond\n              ((list? entry)\n                (cadr entry))\n              (else\n                (quote illegal-program-error))))))))))\n      (interpreter interpreter program (quote ()))))\n",
        depictionCanvas: depictionCanvas,
        editPanel: editPanel,
        editor: editor,
        controlPanel: controlPanel,
        storageKey: 'pixley.js',
        selectElem: selectElem,
        examplePrograms: examplePrograms,
        workerURL: config.workerURL || "../src/pixley-worker.js"
    });
  });
}
