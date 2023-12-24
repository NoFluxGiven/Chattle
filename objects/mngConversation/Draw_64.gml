
state.draw();

///@TODO: Test - DRY

var _xscale = 16;
var _yscale = 4;

var _swidth  = sprite_get_width( sprite );
var _sheight = sprite_get_height( sprite );

var _octantsx = camera_get_view_width( view_camera[0] ) / 8;
var _octantsy = camera_get_view_height( view_camera[0] ) / 8;

var _x = _octantsx * 4;
var _y = _octantsy * 7;

var _textbox_bufferx = 7;
var _textbox_buffery = 7;

var _textbox_width   = ( _swidth * _xscale )
var _textbox_height  = ( _sheight * _yscale )

var _textbox_startx = _x - _textbox_width / 2;
var _textbox_starty = _y - _textbox_height / 2;

var _textbox_endx   = _x + ( _swidth * ( _xscale / 2 ) );
var _textbox_endy   = _y + ( _sheight * ( _yscale / 2 ) );

var _textarea_width  = _textbox_width - _textbox_bufferx * 2;
var _textarea_height = _textbox_height - _textbox_bufferx * 2;

var _textx, _texty;
_textx = _textbox_startx + _textbox_bufferx;
_texty = _textbox_starty + _textbox_buffery;

draw_text( 10, 10, $"{options}\n\n{ChatterboxIsStopped( chatterbox )}\n\n{ChatterboxIsWaiting( chatterbox )}\n\n{typist.get_state()}\n\n{optionIndex}\n\n{region}\n\n{tooltip}" );