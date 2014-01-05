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
    var margin = 3;

    this.init = function(c) {
        canvas = c;
        ctx = canvas.getContext("2d");
    };

    this.depict = function(sexp) {
        canvas.style.display = "block";
        ctx.clearRect(0, 0, canvas.width, canvas.height);
        this.depictList(0, 0, canvas.width, canvas.height, sexp);
    };

    /*
     * Recursively depict this list on the canvas.
     */    
    this.depictList = function(x, y, w, h, sexp) {
        /*
         * Determine the new bounds.
         */
        var newX = x + margin;
        var newY = y + margin;
        var newW = w - (margin * 2);
        var newH = h - (margin * 2);

        /*
         * Determine if we have a Cons cell or an Atom.
         */
        if (sexp.text === undefined) {
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
            while (sexp != null) {
                children.push(sexp.head);
                sexp = sexp.tail;
            }
            var len = children.length;
            //var colour = colourMap[head.text] || 'red';
            ctx.strokeStyle = "black";
            ctx.lineWidth = 1;
            ctx.strokeRect(newX, newY, newW, newH);
            
            var innerW = newW / len;
            
            for (var i = 0; i < len; i++) {
                var innerX = newX + innerW * i;
                this.depictList(innerX, newY, innerW, newH, children[i]);
            }
        } else {
            /*
             * Atom.  Fill the rect in the atom's colour.
             */
            var colour = colourMap[sexp.text] || 'red';
            ctx.fillStyle = colour;
            ctx.fillRect(newX, newY, newW, newH);
        }
    };
};
