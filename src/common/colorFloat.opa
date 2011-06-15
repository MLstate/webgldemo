
type ColorFloat.color = (float, float, float); // as opengl ~ between 0.0 and 1.0

ColorFloat = {{
  from_Color_color(c : Color.color) : ColorFloat.color  =
    (float_of_int(c.r) / 255.0, float_of_int(c.g) / 255.0, float_of_int(c.b) / 255.0);

  random() : ColorFloat.color =
    // we draw color with float, but we read them back as integer
    r() = float_of_int(Random.int(256)) / 255.;
    (r(), r(), r());

}}
