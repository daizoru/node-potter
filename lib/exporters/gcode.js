// Generated by CoffeeScript 1.4.0
(function() {
  var Program, async, fs, wait, _ref,
    __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

  fs = require('fs');

  _ref = require("../toolbox"), wait = _ref.wait, async = _ref.async;

  Program = (function() {

    function Program(name) {
      if (name == null) {
        name = "";
      }
      this.toString = __bind(this.toString, this);

      this.changeTool = __bind(this.changeTool, this);

      this.coolingFan = __bind(this.coolingFan, this);

      this.absolutePositionning = __bind(this.absolutePositionning, this);

      this.b = "0" + name + "\n";
    }

    Program.prototype.absolutePositionning = function() {
      return this.b += "G90\n";
    };

    Program.prototype.coolingFan = function(enable) {
      if (enable == null) {
        enable = true;
      }
      return this.b += enable ? "M106\n" : "M107\n";
    };

    Program.prototype.changeTool = function(id) {
      if (id == null) {
        id = 0;
      }
      return this.b += "M06 " + id + "\n";
    };

    Program.prototype.toString = function() {
      return this.b;
    };

    return Program;

  })();

  module.exports = (function() {

    function exports(path, options) {
      this.path = path;
      this.write = __bind(this.write, this);

      this.close = __bind(this.close, this);

      this.outStream = fs.createWriteStream(this.path, {
        flags: 'w'
      });
      this.onEnd = options.onEnd != null ? options.onEnd : function() {};
      this.headerWritten = false;
      this.nbPoints = options.nbPoints;
      this.program = new Program("1234");
    }

    exports.prototype.close = function() {
      var _this = this;
      return async(function() {
        return _this.onEnd();
      });
    };

    exports.prototype.write = function(x, y, z, material) {
      if (material.id === 0) {
        return;
      }
      return this.outStream.write("" + x + " " + y + " " + z + " " + material.rgbInt + "\n");
    };

    return exports;

  })();

}).call(this);
