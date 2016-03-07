//http://www.lugolabs.com/articles/20-jquery-ui-autocomplete-with-ruby-on-rails
var app = window.app = {};

var getKeys = function(obj){
   var keys = [];
   for(var key in obj){
      keys.push(key);
   }
   return keys;
}

app.Surnames = function() {
  this._input = $('#surnames-search-txt');
  this._initAutocomplete();
};

app.Surnames.prototype = {
  _initAutocomplete: function() {
    this._input
      .autocomplete({
        source: '/surnames',
        appendTo: '#surnames-search-results',
        select: $.proxy(this._select, this)
      })
      .autocomplete('instance')._renderItem = $.proxy(this._render, this);
  },

  _render: function(ul, item) {
    var to_hide = document.getElementById('surnames-search-div');
    if ( to_hide ) {
      to_hide.style.visibility = 'hidden';
    }
    var markup = [
      '<span class="surname">' + item.surname + '</span>',
    ];
    return $('<li>')
      .append(markup.join(''))
      .appendTo(ul);
  },

  _select: function(e, ui) {
    this._input.val(ui.item.surname);
    surname = ui.item.surname;
    return false;
  }
};

app.Names = function() {
  this._input = $('#names-search-txt');
  this._initAutocomplete();
};
	
app.Names.prototype = {
  _initAutocomplete: function() {

    this._input
      .autocomplete({
        source: '/names/'+surname,
        messages: {
          noResults: 'no results', // displays in class "ui-helper-hidden-accessible"
          results: function() {}
        },
        appendTo: '#names-search-results',
        select: $.proxy(this._select, this)
      })
      .autocomplete('instance')._renderItem = $.proxy(this._render, this);
  },

  _render: function(ul, item) {
    var markup = [
      '<span class="fullname">' + item.fullname + ' &nbsp; &nbsp; <small><i>' + item.birth + '</i></small></span>',
    ];
    return $('<li>')
      .append(markup.join(''))
      .appendTo(ul);
  },

  _select: function(e, ui) {
    var hidden = document.getElementById('names-search-uid');
    hidden.value = ui.item.uid;   
    this._input.val( ui.item.fullname );
    return false;
  }
};


