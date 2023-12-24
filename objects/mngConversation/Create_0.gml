sprite_index = noone;

///@TODO: Clean-up

///@TODO: This should load ALL files in the given folder.
ChatterboxLoadFromFile( "lilknight.yarn" );

ChatterboxAddFunction( "pause", function( args ) {
	var duration = args[0];
	state.pause( duration );
} );
ChatterboxAddFunction( "express", function() {} );
ChatterboxAddFunction( "learn", function( args ) {
	array_push( knownConcepts, args[0] );
	
	if ( array_length( args ) > 1 ) {
		tooltips[$ args[0] ] = args[1];
	}
} );
ChatterboxAddFunction( "unlearn", function( args ) {
	var concepts = string_split( args[0], ";" );
	for (var i=0;i<array_length(concepts);i++) {
		var c = concepts[ i];
		
		knownConcepts = array_filter( knownConcepts, method( { concept: c }, function( centrebox_x) {
			return centrebox_x != concept;
		} ) );
	}
	
} );

function getTooltip( name ) {
	if (tooltips[$ name] == undefined) return "";
	
	if (array_contains( knownConcepts, name )) {
		return tooltips[$ name] ?? "";
	}
	
	return "?";
}

chatterbox = ChatterboxCreate( );

sprite = sprDialogueBox;

xscale = 16;
yscale = 4;

swidth  = sprite_get_width( sprite );
sheight = sprite_get_height( sprite );

octantsx = camera_get_view_width( view_camera[0] ) / 8;
octantsy = camera_get_view_height( view_camera[0] ) / 8;
centrebox_x = octantsx * 4;
centrebox_y = octantsy * 7;

state = new SnowState( "idle" );

speedMultiplier = 1;
autoAdvanceTimer = 0;
autoAdvanceEvery = 5;

typist = scribble_typist(false);
typist.in( 0.73, 0 );
typist.character_delay_add( ".", 300 );
typist.character_delay_add( ",", 200 );
typist.sound( snd_tby_speech_default, 20, 0.9, 1.1 );

element = scribble("", "conversation");
element.starting_format( "fntDefault", c_white );

optionsElement = scribble( "", "options" );
optionIndex = -1;
options = [];

optionsFrameTimer = 2;

pauseTime = 0;

region = undefined;

knownConcepts = [];

tooltip = "";
tooltips = {}

text = "";
lastText = "";

state.add( "base", {
	enter: function() {},
	leave: function() {},
	step: function() {},
	advance: function() {},
	skip: function() {},
	stop: function() {},
	select: function() {},
	pause: function( duration ) {
		pauseTime = ceil( ( real( duration ) * 60 ) / ( speedMultiplier * 2 ) );
		state.change( "pause" );
	},
	start: function() {}
} );

state.add_child( "base", "pause", {
	step: function() {
		if ( pauseTime <= 0 ) {
			state.change( "chat" );
		}
		pauseTime --;
	}
} );

state.add_child( "base", "idle", {
	step: function() {
		if ( keyboard_check_pressed( ord( "Z" ) ) ) {
			state.start();
		}
	},
	start: function( filename ) {
		ChatterboxJump( chatterbox, "Start", filename );
		
		state.change( "chat" );
	}
} );

state.add_child( "base", "chat", {
	enter: function() {
		xscale = 16;
		yscale = 4;

		swidth  = sprite_get_width( sprite );
		sheight = sprite_get_height( sprite );

		octantsx = camera_get_view_width( view_camera[0] ) / 8;
		octantsy = camera_get_view_height( view_camera[0] ) / 8;
		centrebox_x = octantsx * 4;
		centrebox_y = octantsy * 7;

		textbox_bufferx = 7;
		textbox_buffery = 7;

		textbox_width   = ( swidth * xscale )
		textbox_height  = ( sheight * yscale )

		textbox_startx = centrebox_x - textbox_width / 2;
		textbox_starty = centrebox_y - textbox_height / 2;

		textbox_endx   = centrebox_x + ( swidth * ( xscale / 2 ) );
		textbox_endy   = centrebox_y + ( sheight * ( yscale / 2 ) );

		textarea_width  = textbox_width - textbox_bufferx * 2;
		textarea_height = textbox_height - textbox_bufferx * 2;

		textx = textbox_startx + textbox_bufferx;
		texty = textbox_starty + textbox_buffery;
		
		text = getCurrentText( chatterbox, tooltips );
	},
	leave: function() {},
	step: function() {
		
		
		typist.in( 0.73 * speedMultiplier, 0 );
		typist.character_delay_add( ".", 300 / speedMultiplier );
		typist.character_delay_add( ",", 200 / speedMultiplier );
		typist.sound( snd_tby_speech_default, 20, 0.9 * max(1, speedMultiplier / 1.5), 1.1 * max(1, speedMultiplier / 1.5) );
		
		optionsFrameTimer --;
		
		speedMultiplier = 1;
		
		if ( keyboard_check_pressed( ord( "Z" ) ) ) {
			state.advance();
		}
		
		if ( keyboard_check( ord( "X" ) ) ) {
			// Skip quickly through dialogue until an option
			if (speedMultiplier <= 1) {
				speedMultiplier = 8;
			}
			if ( typist.get_state() >= 1 && optionIndex < 0 ) {
				autoAdvanceTimer += 1;
				
				if ( autoAdvanceTimer > autoAdvanceEvery ) {
					autoAdvanceTimer = 0;
					state.advance();
				}
			}
		}
		
		if ( typist.get_state() < 1 ) exit;
		
		if ( ChatterboxGetOptionCount( chatterbox ) > 0
			 && typist.get_state() >= 1 ) {
		
			if ( keyboard_check_pressed( vk_up ) ) {
				state.navigate( -1 );
			}
		
			if ( keyboard_check_pressed( vk_down ) ) {
				state.navigate( +1 );
			}
		
			if ( optionIndex < 0
				 && optionsFrameTimer <= 0) {
				 
				options = ChatterboxGetOptionArray( chatterbox );
				optionIndex = 0;
				
				audio_play_sound( sndOh, 10, false, 1.0, 0, 2 );
			}
		}

		try {
			region = element.region_detect( textx, texty, mousecentrebox_x, mousecentrebox_y );
			tooltip = getTooltip( region );
		} catch(err) {
			show_debug_message( err );
			region = undefined;
		}
	},
	
	advance: function( reset=true ) {
		region = undefined;
		tooltip = "";
		if ( typist.get_state() < 1 && text != "" ) {
			typist.skip_to_pause();
			return;
		}
		
		if ( !element.on_last_page() ) {
			element.page( element.get_page() + 1 );
			return;
		}
		
		// We're ready for input
		if ( ChatterboxIsWaiting( chatterbox ) ) {
			ChatterboxContinue( chatterbox );
		// We're selecting an option
		} else {
			state.select();
			state.pause( 0.75 );
		}
		
		text = getCurrentText( chatterbox, tooltips );
		if (reset) {
			typist.reset();
			optionsFrameTimer = 2;
		}
		
		if ( ChatterboxIsStopped( chatterbox ) ) {
			state.change( "idle" );
			return;
		}
		
	},
	stop: function() {},
	select: function() {
		var sound = sndBlip;
		var pitch = 0.7;
		var gain  = 1;
		
		if (array_contains( ChatterboxGetOptionMetadata(chatterbox, optionIndex), "PromiseYes")) {
			sound = sndBlip;
			pitch = 0.4;
			gain = 2;
		}
		
		if (array_contains( ChatterboxGetOptionMetadata(chatterbox, optionIndex), "PromiseNo")) {
			sound = sndOh;
			pitch = 0.4;
			gain = 2;
		}
		
		audio_play_sound( sound, 10, false, gain, 0, pitch );
		ChatterboxSelect( chatterbox, optionIndex );
		
		options = [];
		optionIndex = -1;
	},
	navigate: function( dir=1 ) {
		audio_play_sound( sndBlip, 10, false, 1, 0, 1.15 );
		optionIndex += dir;
		
		if ( optionIndex > array_length( options ) - 1 ) {
			optionIndex = 0;
		}
		
		if ( optionIndex < 0 ) {
			optionIndex = array_length( options ) - 1;
		}
	},
	draw: function() {
		draw_sprite_ext( sprite, 0, centrebox_x, centrebox_y, xscale, yscale, 0, c_white, 1 );
	
		if ( lastText != text ) {
			element = scribble( text )
				.wrap( textarea_width, textarea_height )
				.starting_format( "fntDefault", c_white );
		}
		
		element.draw( textx, texty, typist );
		
		///@TODO: Make each option a separate "instance" to allow for animations.
		if ( optionIndex >= 0 ) {
			with( { index: optionIndex } ) {
				other.optionsElement = scribble(
					string_join_ext( "\n",
						array_map(
							other.options,
							function( centrebox_x, _i ) {
								return index == _i ? $"[ccentrebox_yellow]{centrebox_x.text}[/c]" : centrebox_x.text
							}
						)
					)
				);
			}
			
			optionsElement.draw( textbox_startx, textbox_starty - 77 );
		}
		
		///@TODO: Separate this and make it work more statically
		if ( tooltip != "" ) {
			var elem = scribble( tooltip )
				.wrap( 324, 80 );
			var posx = mousecentrebox_x;
			var posy = mousecentrebox_y - elem.get_height();
			
			draw_sprite_ext( sprTooltipBox, 0, posx, posy, elem.get_width() / 20, elem.get_height() / 20, 0, c_white, 1 );
			
			elem.draw( floor( posx - elem.get_width() / 2 ), floor( posy - elem.get_height() / 2 ) );
		}
		
		
	}
} );