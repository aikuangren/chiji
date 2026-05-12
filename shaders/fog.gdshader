shader_type canvas_item;

uniform vec2 player_pos;
uniform float radius = 350.0;
uniform float softness = 80.0;

void fragment() {
	// FRAGCOORD 是屏幕像素坐标 (0,0) 到 (viewport_w, viewport_h)
	// player_pos 是玩家在屏幕上的像素位置
	
	vec2 uv = FRAGCOORD.xy;
	float dist = distance(uv, player_pos);
	
	// 在玩家周围圆形区域内透明，外部黑色
	float alpha = smoothstep(radius - softness, radius + softness, dist);
	alpha = clamp(alpha, 0.0, 1.0);
	
	COLOR = vec4(0.0, 0.0, 0.0, alpha);
}
