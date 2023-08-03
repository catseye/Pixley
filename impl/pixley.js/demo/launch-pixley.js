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

    var flexContainer = yoob.makeDiv(container);
    flexContainer.className = "flex-container";
    var executionPanel = yoob.makeDiv(flexContainer);
    executionPanel.className = "execution-panel";

    yoob.makeParagraph(executionPanel, "Status:");
    var status = yoob.makePre(executionPanel);

    yoob.makeParagraph(executionPanel, "Result:");
    var output = yoob.makePre(executionPanel);

    yoob.makeParagraph(executionPanel, "Program:");
    var display = yoob.makePre(executionPanel);
    var editor = yoob.makeTextArea(executionPanel);

    var depictionPanel = yoob.makeDiv(flexContainer);
    depictionPanel.className = "depiction-panel";

    yoob.makeParagraph(depictionPanel, "Depiction:");
    var depictionCanvas = yoob.makeCanvas(depictionPanel);

    var pixleyInterpreter = (
      "(lambda (program)" +
      "  (let* ((interpreter (lambda (interpret program env)" +
      "    (let*  ((cadr (lambda (alist)" +
      "              (car (cdr alist))))" +
      "            (null? (lambda (expr)" +
      "              (equal? expr (quote ()))))" +
      "            (find (lambda (self elem alist)" +
      "              (cond" +
      "                ((null? alist)" +
      "                  (quote nothing))" +
      "                (else" +
      "                  (let* ((entry (car alist))" +
      "                         (key   (car entry))" +
      "                         (rest  (cdr alist)))" +
      "                    (cond" +
      "                      ((equal? elem key)" +
      "                        entry)" +
      "                      (else" +
      "                        (self self elem rest))))))))" +
      "            (interpret-args (lambda (interpret-args args env)" +
      "              (cond" +
      "                ((null? args)" +
      "                  args)" +
      "                (else" +
      "                  (let* ((arg  (car args))" +
      "                         (rest (cdr args)))" +
      "                    (cons (interpret interpret arg env) (interpret-args interpret-args rest env)))))))" +
      "            (expand-args (lambda (expand-args formals argvals)" +
      "              (cond" +
      "                ((null? formals)" +
      "                  formals)" +
      "                (else" +
      "                  (let* ((formal       (car formals))" +
      "                         (rest-formals (cdr formals))" +
      "                         (argval       (car argvals))" +
      "                         (rest-argvals (cdr argvals)))" +
      "                    (cons (cons formal (cons argval (quote ()))) (expand-args expand-args rest-formals rest-argvals)))))))" +
      "            (concat-envs (lambda (concat-envs new-env old-env)" +
      "              (cond" +
      "                ((null? new-env)" +
      "                  old-env)" +
      "                (else" +
      "                  (let* ((entry (car new-env))" +
      "                         (rest  (cdr new-env)))" +
      "                    (cons entry (concat-envs concat-envs rest old-env)))))))" +
      "             (call-lambda (lambda (func args env)" +
      "               (let* ((arg-vals (interpret-args interpret-args args env)))" +
      "                  (func arg-vals)))))" +
      "      (cond" +
      "        ((null? program)" +
      "          program)" +
      "        ((list? program)" +
      "          (let* ((tag   (car program))" +
      "                 (args  (cdr program))" +
      "                 (entry (find find tag env)))" +
      "            (cond" +
      "              ((list? entry)" +
      "                (call-lambda (cadr entry) args env))" +
      "              ((equal? tag (quote lambda))" +
      "                (let* ((formals (car args))" +
      "                       (body    (cadr args)))" +
      "                  (lambda (arg-vals)" +
      "                    (let* ((arg-env   (expand-args expand-args formals arg-vals))" +
      "                           (new-env   (concat-envs concat-envs arg-env env)))" +
      "                      (interpret interpret body new-env)))))" +
      "              ((equal? tag (quote cond))" +
      "                (cond" +
      "                  ((null? args)" +
      "                    args)" +
      "                  (else" +
      "                    (let* ((branch   (car args))" +
      "                           (test     (car branch))" +
      "                           (expr     (cadr branch)))" +
      "                      (cond" +
      "                        ((equal? test (quote else))" +
      "                          (interpret interpret expr env))" +
      "                        ((interpret interpret test env)" +
      "                          (interpret interpret expr env))" +
      "                        (else" +
      "                          (let* ((branches (cdr args))" +
      "                                 (newprog (cons (quote cond) branches)))" +
      "                            (interpret interpret newprog env))))))))" +
      "              ((equal? tag (quote let*))" +
      "                (let* ((bindings (car args))" +
      "                       (body     (cadr args)))" +
      "                  (cond" +
      "                    ((null? bindings)" +
      "                      (interpret interpret body env))" +
      "                    (else" +
      "                      (let* ((binding  (car bindings))" +
      "                             (rest     (cdr bindings))" +
      "                             (ident    (car binding))" +
      "                             (expr     (cadr binding))" +
      "                             (value    (interpret interpret expr env))" +
      "                             (new-bi   (cons ident (cons value (quote ()))))" +
      "                             (new-env  (cons new-bi env))" +
      "                             (newprog  (cons (quote let*) (cons rest (cons body (quote ()))))))" +
      "                        (interpret interpret newprog new-env))))))" +
      "              ((equal? tag (quote list?))" +
      "                (list? (interpret interpret (car args) env)))" +
      "              ((equal? tag (quote quote))" +
      "                (car args))" +
      "              ((equal? tag (quote car))" +
      "                (car (interpret interpret (car args) env)))" +
      "              ((equal? tag (quote cdr))" +
      "                (cdr (interpret interpret (car args) env)))" +
      "              ((equal? tag (quote cons))" +
      "                (cons (interpret interpret (car args) env) (interpret interpret (cadr args) env)))" +
      "              ((equal? tag (quote equal?))" +
      "                (equal? (interpret interpret (car args) env) (interpret interpret (cadr args) env)))" +
      "              ((null? tag)" +
      "                tag)" +
      "              ((list? tag)" +
      "                (call-lambda (interpret interpret tag env) args env))" +
      "              (else" +
      "                (call-lambda tag args env)))))" +
      "        (else" +
      "          (let* ((entry (find find program env)))" +
      "            (cond" +
      "              ((list? entry)" +
      "                (cadr entry))" +
      "              (else" +
      "                (quote illegal-program-error))))))))))" +
      "      (interpreter interpreter program (quote ()))))"
    );

    /* --- Make Controller --- */

    launchPixley({
        status: status,
        display: display,
        output: output,
        startButton: startButton,
        stopButton: stopButton,
        wrapButton: wrapButton,
        pixleyInterpreter: pixleyInterpreter,
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
