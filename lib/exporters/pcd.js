// Generated by CoffeeScript 1.4.0
(function() {
  var async, fs, wait, _ref,
    __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

  fs = require('fs');

  _ref = require("../toolbox"), wait = _ref.wait, async = _ref.async;

  module.exports = (function() {

    function exports(path, options) {
      this.path = path;
      this.write = __bind(this.write, this);

      this.writeHeader = __bind(this.writeHeader, this);

      this.close = __bind(this.close, this);

      this.outStream = fs.createWriteStream(this.path, {
        flags: 'w'
      });
      this.onEnd = options.onEnd != null ? options.onEnd : function() {};
      this.headerWritten = false;
      this.nbPoints = options.nbPoints;
      this.writeHeader();
    }

    exports.prototype.close = function() {
      var _this = this;
      return async(function() {
        return _this.onEnd();
      });
    };

    exports.prototype.writeHeader = function() {
      var header, headerOrder, key, value, _i, _len;
      header = {
        version: '.7',
        fields: "x y z rgb",
        size: "4 4 4 4",
        type: "I I I I",
        count: "1 1 1 1",
        width: this.nbPoints,
        height: 1,
        viewpoint: "0 0 0 1 0 0 0",
        points: this.nbPoints,
        data: 'ascii'
      };
      headerOrder = ['version', 'fields', 'size', 'type', 'count', 'width', 'height', 'viewpoint', 'points', 'data'];
      for (_i = 0, _len = headerOrder.length; _i < _len; _i++) {
        key = headerOrder[_i];
        value = header[key];
        this.outStream.write("" + (key.toUpperCase()) + " " + value + "\n");
      }
      return this.headerWritten = true;
    };

    exports.prototype.write = function(position, material) {
      var x, y, z;
      if (material.id === 0) {
        return;
      }
      x = position[0], y = position[1], z = position[2];
      return this.outStream.write("" + x + " " + y + " " + z + " " + material.rgbInt + "\n");
    };

    return exports;

  })();

}).call(this);
