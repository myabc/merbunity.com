$.fn.cycleHighlights = function() {
  var WIDTH = "970px";
  var FREQUENCY = 12000;
  
  var ul = $(this);
  var entries = ul.find("li");
  ul.find("li:not(:eq(0))").css({left: WIDTH});
  
  var current = $(entries[0]);
  var currentIndex = 0;
  var next = null;
  var nextIndex = null;
  var total = entries.length - 1;
  
  // Cycles through each of the features
  var cycle = function() {
    nextIndex = (currentIndex < total ? currentIndex + 1 : 0);
    next = $(entries[nextIndex]);
    current.css({"z-index": 1});
    next.css({"z-index": 2});
    next.animate({left: "0px"}, 600, "swing", hideCurrent);
    window.setTimeout(cycle, FREQUENCY);
  };
  
  var hideCurrent = function() {
    current.css({left: WIDTH});
    current = next;
    currentIndex = nextIndex;
  };
  
  window.setTimeout(cycle, FREQUENCY);
};

$(document).ready(function() {
  $("body").addClass("javascript");
  $("#home ul.highlights").cycleHighlights();
});
