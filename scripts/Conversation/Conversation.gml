
function parseExtendedScribble( text, tooltips={} ) {
	var tooltipNames = struct_get_names( tooltips );
	for ( var i=0;i<array_length( tooltipNames );i++ ) {
		var name = tooltipNames[ i];
		
		text = string_replace_all( text, $"~{name}~", $"[region,{name}][c_orange]{name}[/c][/region]" );
	}
	
	return string_replace_all( text, "~", "" );
}

function getCurrentText( chatterbox, tooltips ) {
	return parseExtendedScribble( ChatterboxGetContentSpeech( chatterbox, 0 ), tooltips );
}