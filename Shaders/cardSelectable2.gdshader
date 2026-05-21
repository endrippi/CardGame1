shader_type canvas_item;
render_mode blend_premul_alpha;

uniform float Line_Smoothness : hint_range(0.0, 0.1) = 0.045;
uniform float Line_Width : hint_range(0.0, 0.2) = 0.09;
uniform float Brightness = 3.0;
uniform float Rotation_deg : hint_range(-90.0, 90.0) = 30.0;
uniform float Distortion : hint_range(1.0, 2.0) = 1.8;
uniform float Speed = 0.7;
uniform float Position : hint_range(0.0, 1.0) = 0.0;
uniform float Position_Min = 0.25;
uniform float Position_Max = 0.5;
uniform float Alpha : hint_range(0.0, 1.0) = 1.0;

// Color of the flare/highlight
uniform vec4 Shine_Color : source_color = vec4(1.0, 1.0, 1.0, 1.0);

vec2 rotate_uv(vec2 uv, vec2 center, float rotation, bool use_degrees) {
	float angle = rotation;

	if (use_degrees) {
		angle = rotation * (3.1415926 / 180.0);
	}

	mat2 rotation_matrix = mat2(
		vec2(cos(angle), -sin(angle)),
		vec2(sin(angle),  cos(angle))
	);

	vec2 delta = uv - center;
	delta = rotation_matrix * delta;

	return delta + center;
}

void fragment() {

	// Original texture color
	vec4 tex = texture(TEXTURE, UV);

	// UV centered around middle
	vec2 center_uv = UV - vec2(0.5, 0.5);

	// Edge distortion
	float gradient_to_edge = max(abs(center_uv.x), abs(center_uv.y));
	gradient_to_edge *= Distortion;
	gradient_to_edge = 1.0 - gradient_to_edge;

	// Rotate UVs for diagonal effect
	vec2 rotated_uv = rotate_uv(
		UV,
		vec2(0.5, 0.5),
		Rotation_deg,
		true
	);

	// Remap position
	float remapped_position;
	{
		float output_range = Position_Max - Position_Min;
		remapped_position = Position_Min + output_range * Position;
	}

	// Animated movement
	float remapped_time = TIME * Speed + remapped_position;
	remapped_time = fract(remapped_time);

	{
		float output_range = 2.0 - (-2.0);
		remapped_time = -2.0 + output_range * remapped_time;
	}

	// Moving diagonal line
	vec2 offset_uv = rotated_uv + vec2(remapped_time, 0.0);

	float line = abs(offset_uv.x);

	line *= gradient_to_edge;
	line = sqrt(line);

	// Smooth edges
	float line_smoothness = clamp(Line_Smoothness, 0.001, 1.0);

	float offset_plus = Line_Width + line_smoothness;
	float offset_minus = Line_Width - line_smoothness;

	float remapped_line;
	{
		float input_range = offset_minus - offset_plus;
		remapped_line = (line - offset_plus) / input_range;
	}

	// Brightness/intensity
	remapped_line *= Brightness;
	remapped_line = min(remapped_line, Alpha);

	// Final flare color
	vec3 shine = Shine_Color.rgb * remapped_line;

	// Additive blending over original texture
	COLOR.rgb = tex.rgb + shine;

	// Preserve original alpha
	COLOR.a = tex.a;
}