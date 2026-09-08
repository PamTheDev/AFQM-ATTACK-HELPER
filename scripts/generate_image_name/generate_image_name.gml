function generate_image_name(imageNumber){
	
	
	var imageNumberS = string(imageNumber);

	// A bit hardcoded solution, but feels faster for this kind of problem
	// formats "uuidNS" to be followed by zeros.
	if (string_length(imageNumberS) == 1) {
		imageNumberS = "000" + imageNumberS;
	} else if (string_length(imageNumberS) == 2) {
		imageNumberS = "00" + imageNumberS;
	} else if (string_length(imageNumberS) == 3) {
		imageNumberS = "0" + imageNumberS;
	}
	
	return imageNumberS;
}