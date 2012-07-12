if (typeof Object.create !== 'function') {
    (function () {
        function F() {}

        Object.create = function (o) {
            F.prototype = o;
            return new F();
        };
    }());
}