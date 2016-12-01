var exec = require('cordova/exec');
  
var VoipPush = function(){
    this._handlers = {
        'voipPushRegister': [],
        'voipPushPayload': [],
        'error': []
    };

};

VoipPush.prototype.register = function(){
    var that = this;
    var success = function(result) {
        if (result && result.hasOwnProperty("eventHandler")){
            that.emit(result.eventHandler, result.data || {});
        }
    };

    // triggered on error
    var fail = function(msg) {
        var e = (typeof msg === 'string') ? new Error(msg) : msg;
        that.emit('error', e);
    };

    setTimeout(function() {
        exec(success, fail, 'VoipPush', 'register', []);
    }, 100);
};

VoipPush.prototype.testMe = function(message){
    var success = function() {};
    var fail = function() {};

    exec(success, fail, 'VoipPush', 'testMe', [message]);
};

VoipPush.prototype.on = function(eventName, callback) {
    if (this._handlers.hasOwnProperty(eventName)) {
        this._handlers[eventName].push(callback);
    }
};

VoipPush.prototype.off = function (eventName, handle) {
    if (this._handlers.hasOwnProperty(eventName)) {
        var handleIndex = this._handlers[eventName].indexOf(handle);
        if (handleIndex >= 0) {
            this._handlers[eventName].splice(handleIndex, 1);
        }
    }
};

VoipPush.prototype.emit = function() {
    var args = Array.prototype.slice.call(arguments);
    var eventName = args.shift();

    if (!this._handlers.hasOwnProperty(eventName)) {
        return false;
    }

    for (var i = 0, length = this._handlers[eventName].length; i < length; i++) {
        var callback = this._handlers[eventName][i];
        if (typeof callback === 'function') {
            callback.apply(undefined,args);
        } else {
            console.log('event handler: ' + eventName + ' must be a function');
        }
    }

    return true;
};

module.exports = {
    init: function(notifyCallback) {
        return new VoipPush();
    }
};