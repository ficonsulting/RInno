jQuery(function($) {
    // Password Input
    var passwordInputBinding = new Shiny.InputBinding();
    $.extend(passwordInputBinding, {
        find: function(scope) {
            return $(scope).find('input[type="password"]');
        },
        getId: function(el) {
            return Shiny.InputBinding.prototype.getId.call(this, el) || el.name;
        },
        getValue: function(el) {
            return md5(el.value);
        },
        setValue: function(el, value) {
            el.value = value;
        },
        subscribe: function(el, callback) {
            $(el).on('keyup.passwordInputBinding input.passwordInputBinding', function(event) {
                callback(true);
            });
            $(el).on('change.passwordInputBinding', function(event) {
                callback(false);
            });
        },
        unsubscribe: function(el) {
            $(el).off('.passwordInputBinding');
        },
        getRatePolicy: function() {
            return {
                policy: 'debounce',
                delay: 250
            };
        }
    });
    Shiny.inputBindings.register(passwordInputBinding, 'shiny.passwordInput');
})