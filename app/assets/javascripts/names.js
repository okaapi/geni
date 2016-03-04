

var getKeys = function(obj){
   var keys = [];
   for(var key in obj){
      keys.push(key);
   }
   return keys;
}

app.Names = function() {
  this._input = $('#names-search-txt');
  this._initAutocomplete();
};
	
app.Names.prototype = {
  _initAutocomplete: function() {
		alert(surname);
    this._input
      .autocomplete({
        source: '/first_names/'+surname,
        appendTo: '#names-search-results',
        select: $.proxy(this._select, this)
      })
      .autocomplete('instance')._renderItem = $.proxy(this._render, this);
  },

  _render: function(ul, item) {

    var markup = [
      '<span class="firstname">' + item.surname + '</span>',
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


