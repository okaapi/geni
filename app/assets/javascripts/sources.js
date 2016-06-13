//http://www.lugolabs.com/articles/20-jquery-ui-autocomplete-with-ruby-on-rails
if ( !app ) {
  var app = window.app = {};
}

app.Sources = function() {
  this._input = $('#sources-search-txt');
  this._initAutocomplete();
};
	
app.Sources.prototype = {
  _initAutocomplete: function() {

    this._input
      .autocomplete({
        source: '/sources_for_term',
        messages: {
          noResults: 'no results', // displays in class "ui-helper-hidden-accessible"
          results: function() {}
        },
        appendTo: '#sources-search-results',
        //focus: $.proxy(this._focus, this),   //moves the list item into the box... no refinement
        select: $.proxy(this._select, this)
      })
      .autocomplete('instance')._renderItem = $.proxy(this._render, this);
  },

  _render: function(ul, item) {
    var markup = [
      '<span class="fullname">' + item.title + '</span>',
    ];
    return $('<li>')
      .append(markup.join(''))
      .appendTo(ul);
  },

  _select: function(e, ui) {
    var hidden = document.getElementById('sources-search-sid');
    hidden.value = ui.item.sid;   
    this._input.val( ui.item.title );
    return false;
  },
  
  _focus: function(e, ui) {
    var hidden = document.getElementById('sources-search-sid');
    hidden.value = ui.item.sid;   
    this._input.val( ui.item.title );
    return false;
  }
};


