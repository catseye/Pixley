/*
 * Depicts a Pixley program (or, really, any S-expression) as a colourful
 * set of nested rectangles.
 *
 * requires pixley.js
 */

/*
 * We want to decorate S-expressions with information about where they're
 * depicted and what size they are, so we can't just use `null` for the
 * empty list.
 */
var EmptyList = function() {
    this.toString = function() {
        return '';
    };
};

function PixleyDepictor() {
    var canvas;
    var ctx;
    var margin = 3;
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
        sexp = cloneSexp(sexp);
        canvas.style.display = "block";
        this.transformNullsToEmptyLists(sexp);
        this.decorateSexp(0, 0, sexp);
        canvas.width = sexp.width;
        canvas.height = sexp.height;
        // this is implied by the canvas size change:
        // ctx.clearRect(0, 0, canvas.width, canvas.height);
        this.depictSexp(0, 0, sexp);
    };

    // this method had side-effects; it modified sexp in-place
    this.transformNullsToEmptyLists = function(sexp) {
        if (sexp === null) {
            // what can we do?  this shouldn't happen
            return;
        } else if (sexp.text === undefined) {
            while (sexp !== null) {
                if (sexp.head === null) {
                    sexp.head = new EmptyList();
                } else {
                    this.transformNullsToEmptyLists(sexp.head);
                }
                sexp = sexp.tail;
            }
        } else {
            return;
        }
    };

    /*
     * Decorate all Cons and Atom cells in the s-expression with
     * some details about how to depict them on the canvas, mainly
     * the width and the height which the s-expression will occupy.
     */
    this.decorateSexp = function(x, y, sexp) {
        /*
         * Determine if we have a Cons cell or an Atom.
         */
        if (sexp instanceof EmptyList) {
            /*
             * Empty list.  Fill in width and height.
             */
            sexp.width = blockSize;
            sexp.height = blockSize;
        } else if (sexp.text === undefined) {
            /*
             * Cons cell.
             * First, determine if it has an atom at its head.
             */
            var head = sexp.head;
            if (head.text !== undefined) { // head entry is an atom
                sexp.startsWithAtom = true;
            }
            /*
             * Next, find the extents of the children, then derive
             * the extents of the cons cell, and fill them in.
             */
            var children = [];
            var origSexp = sexp;
            if (sexp.startsWithAtom) {
                // for the purposes of determining the bounding box size,
                // skip the head atom, as we'll be drawing the entire list
                // in that colour -- unless the list contains *only* the
                // head atom, in which case, we still want to draw that.
                // TODO: maybe handle this better; special case, smaller box.
                if (sexp.tail !== null) {
                    sexp = sexp.tail;
                }
            }
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

            origSexp.horizontal = false;
            for (var i = 0; i < len; i++) {
                // alert(i + '...' + w);
                if (origSexp.horizontal) {
                    w += children[i].width || 0;
                    if (children[i].height + margin * 2 > h) {
                        h = children[i].height + margin * 2;
                    }
                } else {
                    h += children[i].height || 0;
                    if (children[i].width + margin * 2 > w) {
                        w = children[i].width + margin * 2;
                    }
                }
            }

            if (origSexp.horizontal) {
                w = w + margin * (len + 1);
            } else {
                h = h + margin * (len + 1);
            }
            origSexp.width = w;
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
    this.depictSexp = function(x, y, sexp, parentColour) {
        /*
         * Determine if we have a Cons cell or an Atom.
         */
        if (sexp instanceof EmptyList) {
            /*
             * Empty list.  Fill the rect in white, w/black border.
             */
            ctx.fillStyle = 'white';
            ctx.fillRect(x - 0.5, y - 0.5, sexp.width, sexp.height);
            ctx.strokeStyle = 'black';
            ctx.strokeRect(x - 0.5, y - 0.5, sexp.width, sexp.height);
        } else if (sexp.text === undefined) {
            /*
             * Cons cell.  Get the list into a more Javascript-y data structure.
             */
            var origSexp = sexp;

            var children = [];
            if (sexp.startsWithAtom) {
                sexp = sexp.tail;
            }
            while (sexp != null) {
                children.push(sexp.head);
                sexp = sexp.tail;
            }
            var len = children.length;

            var colour = 'white';
            if (origSexp.startsWithAtom) {
               // If there's a head atom, fill in rect with head atom's colour
               colour = this.getColour(origSexp.head.text);
            }            
            ctx.fillStyle = colour;
            ctx.fillRect(x - 0.5, y - 0.5, origSexp.width, origSexp.height);
            ctx.strokeStyle = "black";
            ctx.lineWidth = 1;
            ctx.strokeRect(x - 0.5, y - 0.5, origSexp.width, origSexp.height);

            var innerX = x + margin;
            var innerY = y + margin;
            for (var i = 0; i < len; i++) {
                if (children[i] === null) {
                    continue;
                }
                this.depictSexp(innerX, innerY, children[i], colour);
                if (origSexp.horizontal) {
                    innerX += children[i].width + margin;
                } else {
                    innerY += children[i].height + margin;
                }
            }
        } else {
            /*
             * Atom.  Fill the rect in the atom's colour.
             */
            var colour = this.getColour(sexp.text);
            ctx.fillStyle = colour;
            ctx.fillRect(x - 0.5, y - 0.5, sexp.width, sexp.height);
            if (colour === parentColour) {
                ctx.strokeStyle = 'white';
                ctx.strokeRect(x - 0.5, y - 0.5, sexp.width, sexp.height);
            }
        }
    };
};
