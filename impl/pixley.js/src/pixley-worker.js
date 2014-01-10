importScripts('pixley.js');

addEventListener('message', function(e) {
    if (e.data[0] === 'eval') {
        postMessage(depict(runPixley(e.data[1])));
    }
});
