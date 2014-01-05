/*
 * Depicts a Pixley program (or, really, any S-expression) as a colourful
 * set of nested rectangles.
 *
 * requires pixley.js
 */
var colourMap = {
    'cons': 'yellow',
    'quote': 'blue',
    'a': 'pink',
    'b': 'orange',
    'lambda': 'green',
    'let*': 'brown'
};

function PixleyDepictor() {
    var canvas;
    var ctx;
    var margin = 2;
    var blockSize = 10;

    this.init = function(c) {
        canvas = c;
        ctx = canvas.getContext("2d");
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
            var colour = colourMap[sexp.text] || 'red';
            ctx.fillStyle = colour;
            ctx.fillRect(x, y, sexp.width, sexp.height);
        }
    };
};
