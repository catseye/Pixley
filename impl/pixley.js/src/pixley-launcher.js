function launchPixley(cfg) {
    var c = new PixleyController();
    c.init({
        status: cfg.status,
        display: cfg.display,
        output: cfg.output,
        workerURL: cfg.workerURL
    });

    cfg.startButton.onclick = function() { c.start(); };
    cfg.stopButton.onclick = function() { c.stop(); };
    cfg.wrapButton.onclick = function() {
        c.wrapWith(cfg.pixleyInterpreter);
    };

    c.depictor = new PixleyDepictor();
    c.depictor.init(cfg.depictionCanvas);

    var sourceManager = (new yoob.SourceManager()).init({
        'panelContainer': cfg.editPanel,
        'editor': cfg.editor,
        'hideDuringEdit': [
            cfg.display,
            cfg.status
        ],
        'disableDuringEdit': [cfg.controlPanel],
        'storageKey': cfg.storageKey,
        'onDone': function() {
            /* Apparently this gets called as soon as the sourceManager
               has been initialized... but we don't have any editor text
               yet at that point.  But it will get called again, when
               we make the sourceManager.  So, ... we check first. */
            if (this.getEditorText()) {
                c.load(this.getEditorText());
            }
        }
    });
    
    var presetManager = (new yoob.PresetManager()).init({
        selectElem: cfg.selectElem,
    });
    function makeCallback(sourceText) {
      return function(id) {
        sourceManager.loadSource(sourceText);
      }
    }
    for (var i = 0; i < cfg.examplePrograms.length; i++) {
      presetManager.add(cfg.examplePrograms[i][0], makeCallback(cfg.examplePrograms[i][1]));
    }
    presetManager.select(cfg.examplePrograms[0][0]);
}
