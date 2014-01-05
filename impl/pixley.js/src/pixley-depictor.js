/*
 * Depicts a Pixley program (or, really, any S-expression) as a colourful
 * set of nested rectangles.
 *
 * requires pixley.js
 */
function PixleyDepictor() {
    var canvas;
    var ctx;
    var margin = 2;
    var blockSize = 10;

    this.init = function(c) {
        canvas = c;
        ctx = canvas.getContext("2d");
        this.colourMap = {
            'car':    '#6949d7',
            'cdr':    '#1f0772',
            'cond':   'yellow',
            'cons':   '#3714b0',
            'else':   'red',
            'equal?': 'green',
            'lambda': '#6f0aaa',
            'let*':   'brown',
            'list?':  'aquamarine',
            'quote':  'purple',
        };
        
        this.availableColours = [
            '#00c0c0',
            '#c000c0',
            '#c0c000',
            '#00a0a0',
            '#a000a0',
            '#a0a000',
            '#008080',
            '#006060',
            '#004040',
            '#002020',
            '#800080',
            '#600060',
            '#400040',
            '#200020',
            '#808000',
            '#606000',
            '#404000',
            '#202000'
        ];
        this.availableIndex = 0;
    };

    this.getColour = function(text) {
        var entry = this.colourMap[text];
        if (entry) return entry;
        if (this.availableIndex >= this.availableColours.length) {
            //alert('Ran out of unique colours!');
            this.availableIndex = 0;
        }
        entry = this.availableColours[this.availableIndex];
        this.colourMap[text] = entry;
        this.availableIndex++;
        return entry;
    };

    this.depict = function(sexp) {
        canvas.style.display = "block";
        this.decorateSexp(0, 0, sexp);
        canvas.width = sexp.width;
        canvas.height = sexp.height;
        // this is implied by the canvas size change:
        // ctx.clearRect(0, 0, canvas.width, canvas.height);
        this.depictSexp(0, 0, sexp);
    };

    /*
     * Decorate all Cons and Atom cells in the s-expression with
     * some details about how to depict them on the canvas.
     */
    this.decorateSexp = function(x, y, sexp) {
        /*
         * Determine if we have a Cons cell or an Atom.
         */
        if (sexp === null) {
            /*
             * Empty list.
             */
        } else if (sexp.text === undefined) {
            /*
             * Cons cell.  Find the extents of the children, then derive
             * the extents of the cons cell, and fill them in.
             */
            var children = [];
            var origSexp = sexp;
            while (sexp != null) {
                children.push(sexp.head);
                sexp = sexp.tail;
            }
            var len = children.length;

            for (var i = 0; i < len; i++) {
                this.decorateSexp(x, y, children[i]);
            }

            var w = 0;
            var h = 0;

            for (var i = 0; i < len; i++) {
                if (children[i] === null) {
                    continue;
                }
                w += children[i].width;
                if (children[i].height + margin * 2 > h) {
                    h = children[i].height + margin * 2;
                }
            }

            origSexp.width = w + margin * (len + 1);
            origSexp.height = h;
        } else {
            /*
             * Atom.  Fill in width and height.
             */
            sexp.width = blockSize;
            sexp.height = blockSize;
        }
    };

    /*
     * Recursively depict this s-expression on the canvas.
     */
    this.depictSexp = function(x, y, sexp) {
        /*
         * Determine if we have a Cons cell or an Atom.
         */
        if (sexp === null) {
            /*
             * Empty list.
             */
        } else if (sexp.text === undefined) {
            /*
             * Cons cell.  Get the list into a more Javascript-y data structure.
             */
            /*
            var head = sexp.head;
            if (head.text === undefined) {
                alert(head + ' is not an atom');
            }
            */
            var children = [];
            var origSexp = sexp;
            while (sexp != null) {
                children.push(sexp.head);
                sexp = sexp.tail;
            }
            var len = children.length;
            ctx.strokeStyle = "black";
            ctx.lineWidth = 1;
            ctx.strokeRect(x - 0.5, y - 0.5, origSexp.width, origSexp.height);
            
            var innerX = x + margin;
            for (var i = 0; i < len; i++) {
                if (children[i] === null) {
                    continue;
                }
                this.depictSexp(innerX, y + margin, children[i]);
                innerX += children[i].width + margin;
            }
        } else {
            /*
             * Atom.  Fill the rect in the atom's colour.
             */
            var colour = this.getColour(sexp.text);
            ctx.fillStyle = colour;
            ctx.fillRect(x, y, sexp.width, sexp.height);
        }
    };
};
