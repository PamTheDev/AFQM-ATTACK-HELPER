function convert_gif_gml(_gif_path, _sprite_root){
	show_debug_message("convert_gif_gml - " + _gif_path);
	show_debug_message("convert_gif_gml - " + _sprite_root);
	
	var _sprite_name = filename_name(filename_change_ext(_gif_path, ""));
	
	var _new_dir = _sprite_root + _sprite_name; 
	
	// Create Folder
	directory_create(_new_dir);
	
	// Import Sprite
	var _spr = sprite_add_gif(_gif_path, 0, 0, [1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1]);
	
	// Loop through each frame and save as png
	for(var i = 0; i < sprite_get_number(_spr); i++){
		var _sprite_path = _new_dir + "/" + generate_image_name(i) + ".png";
		sprite_save(_spr, i, _sprite_path);
	}
	
	show_debug_message("convert_gif_gml - " + "Sprite Created at: " + _new_dir);
	
	
	var _sprite_json_buffer = buffer_create(1, buffer_grow, 1);
	
	buffer_write(_sprite_json_buffer, buffer_string, json_stringify(
	{	
		"type":0,
		"x_origin": sprite_get_width(_spr)/2,
		"y_origin": sprite_get_height(_spr)/2
	}));
	
	
	var _sprite_json_path = _new_dir + "/" + "sprite.json"
	buffer_save(_sprite_json_buffer, _sprite_json_path);
	buffer_delete(_sprite_json_buffer)
	
	show_debug_message("convert_gif_gml - " + "sprite.json Created at: " + _sprite_json_path);
	
	sprite_delete(_spr);
	
	// Save txt
	var _buffer = buffer_create(string_length(""), buffer_fixed, 1);
	buffer_write(_buffer, buffer_string, "");
	buffer_save(_buffer, _new_dir + "/" + "conversion_done.txt");
	buffer_delete(_buffer);
	
	show_debug_message("convert_gif_gml - " + "conversion_done Created at: " + _sprite_json_path);
	
}