/* Author:
    Max Degterev @suprMax
    Valerio Di Donato @drowne
    
    JQM fast buttons without nasty ghostclicks.
    Highly inspired by http://code.google.com/mobile/articles/fast_buttons.html
    
    Usage
    
    live:
    $('#someid').onpress(function(event){});
    $('#someid').offpress(function(event){});
    
    TODO: find a way to remove handleTouchStart handler as well
*/
var isTouch = {};

(function($) {
    isTouch = (window.hasOwnProperty('ontouchstart'));

    var ghostsLifeTime = 1000;
    
    var normalizeArgs = function(args) {
        var callback,
            selector;
            
        if (typeof args[0] === 'function') {
            callback = args[0];
        }
        else {
            selector = args[0];
            callback = args[1];
        }
        return [selector, callback];
    };

    if (isTouch) {
        var ghosts = [];

        var touches = {},
            $doc = $(document),
            hasMoved = false,
            handlers = {};
            
        var handleTouchStart = function(e) {
            e.stopPropagation();
            touches.x = e.originalEvent.touches[0].pageX;
            touches.y = e.originalEvent.touches[0].pageY;
            hasMoved = false;
        };

        var handleTouchMove = function(e) {
            if (Math.abs(e.originalEvent.touches[0].pageX - touches.x) > 10 || Math.abs(e.originalEvent.touches[0].pageX - touches.y) > 10) {
                hasMoved = true;
            }
        };

        var removeGhosts = function() {
            ghosts.splice(0, 2);
        };

        var handleGhosts = function(e) {
            var i, l;
            for (i = 0, l = ghosts.length; i < l; i += 2) {
                if (Math.abs(e.pageX - ghosts[i]) < 25 && Math.abs(e.pageY - ghosts[i + 1]) < 25) {
                    e.stopPropagation();
                    e.preventDefault();
                }
            }
        };

        $doc.live('click', handleGhosts);
        $doc.live('touchmove', handleTouchMove);

        $.fn.onpress = function() {
            var args = normalizeArgs(arguments);
            
            var handleTouchEnd = function(e) {
                e.stopPropagation();

                if (!hasMoved) {
                    args[1].call(this, e);
                    ghosts.push(touches.x, touches.y);
                    window.setTimeout(removeGhosts, ghostsLifeTime);
                }
            };
            
            handlers[args[1]] = handleTouchEnd;

            if (args[0]) {
                this.live('touchstart.onpress', args[0], handleTouchStart);
                this.live('touchend.onpress', args[0], handleTouchEnd);
                this.live('press', args[0], args[1]);
            }
            else {
                this.live('touchstart.onpress', handleTouchStart);
                this.live('touchend.onpress', handleTouchEnd);
                this.live('press', args[1]);
            }
        };
        
        $.fn.offpress = function() {
            var args = normalizeArgs(arguments);
            if (args[1]) {
                if (args[0]) {
                    this.die('.onpress', args[0], handlers[args[1]]);
                    this.die('press', args[0], args[1]);
                }
                else {
                    this.die('.onpress', handlers[args[1]]);
                    this.die('press', args[1]);
                }
                delete handlers[args[1]];
            }
            else {
                if (args[0]) {
                    this.die('.onpress', args[0]);
                    this.die('press', args[0]);
                }
                else {
                    this.die('.onpress');
                    this.die('press');
                }
            }
        };
    }
    else {
        $.fn.onpress = function() {
            var args = normalizeArgs(arguments);
            if (args[0]) {
                this.live('click.onpress', args[0], args[1]);
                this.live('press.onpress', args[0], args[1]);
            }
            else {
                this.live('click.onpress', args[1]);
                this.live('press.onpress', args[1]);
            }
            
        };
        $.fn.offpress = function() {
            var args = normalizeArgs(arguments);
            args[0] ? this.die('.onpress', args[0], args[1]) : this.die('.onpress', args[1]);
        };
    }
}(jQuery));
