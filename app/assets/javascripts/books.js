//http://www.lugolabs.com/articles/20-jquery-ui-autocomplete-with-ruby-on-rails
var app = window.app = {};

var getKeys = function(obj){
   var keys = [];
   for(var key in obj){
      keys.push(key);
   }
   return keys;
}

app.Books = function() {
  this._input = $('#books-search-txt');
  this._initAutocomplete();
};

app.Books.prototype = {
  _initAutocomplete: function() {
    this._input
      .autocomplete({
        source: '/surnames',
        appendTo: '#books-search-results',
        select: $.proxy(this._select, this)
      })
      .autocomplete('instance')._renderItem = $.proxy(this._render, this);
  },

  _render: function(ul, item) {

    var markup = [
      '<span class="surname">' + item.surname + '</span>',
    ];
    return $('<li>')
      .append(markup.join(''))
      .appendTo(ul);
  },

  _select: function(e, ui) {
    this._input.val(ui.item.surname);
    return false;
  }
};


