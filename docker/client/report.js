(function () {
    var oldHandler = window.onerror;

    window.onerror = function (message, url, line, column, e) {
        oldHandler && oldHandler();
        var xhr,
            error =  {
                message: message,
                url: url,
                line: line,
                column: column,
                stack: e && e.stack || ''
            };

        if (e && e.stack) {
            error.processedStack = e.stack
                .split('\n')
                .map(function (item) {
                    var match = item.match(/^ *at ([^ ]*) \((.*):([0-9]+):([0-9]+)\)$/);
                    return !match || {
                        fn: match[1],
                        file: match[2],
                        line: match[3],
                        column: match[4]
                    };
                })
                .filter(function (item) { return typeof item == 'object'; });
        }

        xhr = new XMLHttpRequest();
        xhr.open("POST", document.querySelector('.js_post-url').value || '//localhost/', true);

        xhr.send(JSON.stringify({
            project: 'buildserver',
            error: error,
            doc: window.location.href,
            mapUrl: document.querySelector('.js_map-url').value
        }));
    };
})();

