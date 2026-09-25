folders_list = {};

var _sounds_root = working_directory + "sounds/";

if (directory_exists(_sounds_root))
{
    // Discover parent folders.
    var _folder_name = file_find_first(
        _sounds_root + "*",
        fa_directory
    );

    while (_folder_name != "")
    {
        var _folder_path = _sounds_root + _folder_name + "/";

        if (
            _folder_name != "." &&
            _folder_name != ".." &&
            directory_exists(_folder_path)
        )
        {
            folders_list[$ _folder_name] = {
                path: _folder_path,
                subfolders: {}
            };
        }

        _folder_name = file_find_next();
    }

    file_find_close();

    // Get the parent folder names from the struct.
    var _parent_names = variable_struct_get_names(folders_list);

    for (var i = 0; i < array_length(_parent_names); i++)
    {
        var _parent_name = _parent_names[i];
        var _parent = folders_list[$ _parent_name];

        // Discover this parent's subfolders.
        var _subfolder_name = file_find_first(
            _parent.path + "*",
            fa_directory
        );

        while (_subfolder_name != "")
        {
            var _subfolder_path =
                _parent.path + _subfolder_name + "/";

            if (
                _subfolder_name != "." &&
                _subfolder_name != ".." &&
                directory_exists(_subfolder_path)
            )
            {
                _parent.subfolders[$ _subfolder_name] = {
                    path: _subfolder_path,
                    sounds: []
                };
            }

            _subfolder_name = file_find_next();
        }

        file_find_close();

        // Discover sounds inside each subfolder.
        var _subfolder_names =
            variable_struct_get_names(_parent.subfolders);

        for (
            var j = 0;
            j < array_length(_subfolder_names);
            j++
        )
        {
            var _current_subfolder_name = _subfolder_names[j];
            var _current_subfolder =
                _parent.subfolders[$ _current_subfolder_name];

            var _sound_name = file_find_first(
                _current_subfolder.path + "*",
                fa_none
            );

            while (_sound_name != "")
            {
                var _full_sound_path =
                    _current_subfolder.path + _sound_name;

                if (!directory_exists(_full_sound_path))
                {
                    var _extension =
                        string_lower(filename_ext(_sound_name));

                    if (
                        _extension == ".ogg" ||
                        _extension == ".wav" ||
                        _extension == ".mp3"
                    )
                    {
                        array_push(
                            _current_subfolder.sounds,
                            _sound_name
                        );
                    }
                }

                _sound_name = file_find_next();
            }

            file_find_close();
        }
    }
}

show_debug_message(json_stringify(folders_list));