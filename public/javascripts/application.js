$( function() { 
    $( 'code' ).chili(); //try to comment this line to see the difference 

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