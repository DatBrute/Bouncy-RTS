shader_type canvas_item;

uniform vec4 from :source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform vec4 to :source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform float sensitivity = 0.1;

void fragment()
{
	float diff = distance(from, COLOR);
	if(diff < sensitivity){
		COLOR = to;
	}else{
		COLOR = COLOR;
	}
}