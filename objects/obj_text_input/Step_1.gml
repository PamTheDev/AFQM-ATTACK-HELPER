
var input_w = 32 * image_xscale;
var input_h = 32 * image_yscale;

highlighted =
    mx >= x &&
    mx <= x + input_w &&
    my >= y &&
    my <= y + input_h;