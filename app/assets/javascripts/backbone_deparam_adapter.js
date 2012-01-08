// http://stackoverflow.com/questions/7445353/key-value-pair-params-handling-in-backbone-js-router
(function(){
  var deparam = function(paramString){
      var result = {};
      if( ! paramString){
          return result;
      }
      $.each(paramString.split('&'), function(index, value){
          if(value){
              var param = value.split('=');
              result[param[0]] = param[1];
          }
    });
    return result;
  };

  Backbone.Router.prototype.oldExtractParameters = Backbone.Router.prototype._extractParameters;
  Backbone.Router.prototype._extractParameters = function(route, fragment) {
    var result = route.exec(fragment).slice(1);
    result.unshift(deparam(result[result.length-1]));
    return result.slice(0,-1);
  }
})();
