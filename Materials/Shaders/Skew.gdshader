shader_type canvas_item;

uniform float skew_x = 0.5;
uniform float skew_y = 0.5;

void vertex()
{
	float vertPosX = (-VERTEX.y * skew_x) + VERTEX.x;
	float vertPosY = (-VERTEX.x * skew_y) + VERTEX.y;
	VERTEX.x = vertPosX;
	VERTEX.y = vertPosY;
}