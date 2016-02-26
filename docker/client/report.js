(function () {
    var oldHandler = window.onerror;

    window.onerror = function (message, url, line, column, e) {
        oldHandler && oldHandler();
        var xhr;
      
        xhr = new XMLHttpRequest();
        xhr.open("POST", document.querySelector('.js_post-url').value || '//localhost/', true);
        xhr.send(JSON.stringify({
            project: 'buildserver',
            error: {
                message: message,
                url: url,
                line: line,
                column: column,
                stack: e && e.stack || ''
            },
            doc: window.location.href,
            mapUrl: document.querySelector('.js_map-url').value
        }));
    };
})();

