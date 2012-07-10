/*
 * https://developer.mozilla.org/en/JavaScript/Reference/Global_Objects/Function/bind
 */
if (!Function.prototype.bind) {
    Function.prototype.bind = function (oThis) {
        if (typeof this !== "function") { // closest thing possible to the ECMAScript 5 internal IsCallable function
            throw new TypeError("Function.prototype.bind - what is trying to be fBound is not callable");
        }
        var aArgs = Array.prototype.slice.call(arguments, 1),
            fToBind = this,
            FNOP = function () {},
            fBound = function () {
                var that = this instanceof FNOP ? this : oThis || window;
                return fToBind.apply(that, aArgs.concat(Array.prototype.slice.call(arguments)));
            };
        FNOP.prototype = this.prototype;
        fBound.prototype = new FNOP();
        return fBound;
    };
}