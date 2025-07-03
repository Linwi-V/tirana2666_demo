shader_type canvas_item;

uniform vec2 base_displacement = vec2(0.0, 0.0); //Base movement
uniform float repetion_x = 0.0; //The sine wave repetition
uniform float scale_x = 0.0; //The displacement on the x axes scale,
uniform float speed_x = 0.0; //The speed of the movement,


uniform int color_count; //The amount of colors in the texture
uniform sampler2D pallet; //The pallet whit dimensions (color_count)x(frame_count) pixels
uniform float fps; //The fps of the animations
uniform int frame_count; //The number of frames of the pallet for te animation



void fragment() {
	float pixel = 1.0 / TEXTURE_PIXEL_SIZE.y;

	vec2 display = TIME *  base_displacement;
	vec2 uv = UV  + display;

	float move_x =  TEXTURE_PIXEL_SIZE.x *scale_x *  sin(repetion_x*uv.y + TIME*speed_x);
	move_x *= float(int(UV.y * pixel) % 2) * 2.0 -1.0;

	uv = vec2(uv.x + move_x, uv.y);
	vec4 text = texture(TEXTURE, uv);

COLOR = text;
	for (int i = 0; i < color_count; i++) {
		vec4 initial_color = texelFetch(pallet, ivec2(i, 0), 0);
		vec4 replace_color = texelFetch(pallet, ivec2(i, int(TIME * fps) % frame_count), 0);
		if(text == initial_color){
			COLOR = replace_color;
			break;
		}
	}


}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
