//http://www.lugolabs.com/articles/20-jquery-ui-autocomplete-with-ruby-on-rails
if ( !app ) {
  var app = window.app = {};
}

app.Names = function() {
  this._input = $('#names-search-txt');
  this._initAutocomplete();
};
	
app.Names.prototype = {
  _initAutocomplete: function() {

    this._input
      .autocomplete({
        source: '/names_for_term',
        messages: {
          noResults: 'no results', // displays in class "ui-helper-hidden-accessible"
          results: function() {}
        },
        appendTo: '#names-search-results',
        //focus: $.proxy(this._focus, this),   //moves the list item into the box... no refinement
        select: $.proxy(this._select, this)
      })
      .autocomplete('instance')._renderItem = $.proxy(this._render, this);
  },

  _render: function(ul, item) {
    var markup = [
      '<span class="fullname">' + item.fullname + ' &nbsp; &nbsp; <small><i>' + item.birth + ' '
      + item.tree + '</i></small></span>',
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
  },
  
  _focus: function(e, ui) {
    var hidden = document.getElementById('names-search-uid');
    hidden.value = ui.item.uid;   
    this._input.val( ui.item.fullname );
    return false;
  }
};


