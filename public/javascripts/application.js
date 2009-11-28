$( function() {
    // chili(); //try to comment this line to see the difference

  // set a confirm on delete buttons
  $('.delete button').click(function(){
   if(!confirm("You cannot undo this delete.\nYou will lose all information.\nAre you sure you want to continue?")){
    return false;
   }
  });

  // Make collapsing help sections
  $('.help').click(function(event){
   $(this).children('.box_content').slideToggle();
  }).children('.box_content').hide();


   // Set the display for definition lists
  $('dt').click(function(event){
   $(event.target).next("dd").slideToggle();
  });

  // Set the style of the DT and stuff under it.
  $('dl')
     .children('dd')
    .css({display : 'none'})
    .end()
    .children('dt')
    .css({ "text-decoration" : "underline", cursor : "pointer"});


} );
