use fmt;
use types::c;
use math;
type Color = struct {
	// Color red value
	r: c::uchar,
	// Color green value
	g: c::uchar,
	// Color blue value
	b: c::uchar,
	// Color alpha value
	a: c::uchar,
};
type Rectangle = struct {
	// The coord of the left-top corner
	x: f32,
	y: f32,
	// width and height
	width: f32,
	height: f32,
};

type Brick = struct {
	rec: Rectangle,
	alive: bool,
};

type Position = struct {
	x: f32,
	y: f32,
};
const RED: Color = Color {r = 230, g = 41, b = 55, a = 255};
const DARKGRAY: Color = Color {r = 80, g = 80, b = 80, a = 255};
const RAYWHITE: Color = Color {r = 245, g = 245, b = 245, a = 255};
const BLUE: Color= Color { r= 0, g = 121, b = 241, a = 255 };
@symbol("InitWindow") fn init_window(int, int, *c::char) void;
@symbol("WindowShouldClose") fn window_should_close() bool;
@symbol("BeginDrawing") fn begin_drawing() void;
@symbol("EndDrawing") fn end_drawing() void;
@symbol("CloseWindow") fn close_window() void;
@symbol("ClearBackground") fn clear_background(color: Color) void;
@symbol("DrawRectangleRec") fn draw_rectangle(Rectangle, Color) void;
@symbol("GetFrameTime") fn get_delta_time() f32;
@symbol("IsKeyDown") fn is_key_down(int) bool;
@symbol("CheckCollisionRecs") fn check_collision_rec(Rectangle, Rectangle) bool;

fn get_new_pos(old_pos: Position, speed: f32, dx: f32, dy: f32, dt: f32) Position = {
	let nx = old_pos.x + (dx*speed*dt);
	let ny = old_pos.y + (dy*speed*dt);
	return Position {x=nx, y=ny};
};

const PROJ_SPEED: f32 = 100.0;
const BAR_SPEED: f32 = 150.0;
const BRICK_NUM: int = 5*3;
const BRICK_WIDTH: f32 = ((800/5)-10): f32;
const BRICK_HEIGHT: f32 = 30.0;

export fn main() void = {
	let window_title = c::fromstr("Hello from Hare")!;
	defer free(window_title);
	let projectile = Rectangle {x = 0f32, y = 0f32, width = 30f32, height=30f32};
	let proj_old_pos = Position {x = 0f32, y = 0f32};
	let proj_new_pos = Position {x = 0f32, y = 0f32};
	let bar = Rectangle {x = 350.0, y = 500.0, width = 150.0, height = 15.0};
	let bar_old_pos = Position {x = 350f32, y = 500f32};
	let bar_new_pos = Position {x = 350f32, y = 500f32};
	let dx: f32 = 1.0;
	let dy: f32 = 1.0;
	let dt: f32 = 0.0;
	let bricks: [5*3]Brick = [Brick {rec = Rectangle {x= 0.0, y = 0.0, width = 0.0, height = 0.0}, alive = false, }...];
	// Make the bricks alive and give them the right position and dimensions
	let brick_x: f32 = 15.0;
	let brick_y: f32 = 0.0;
	let iter = 0;
	for (let brick &.. bricks) {
		(*brick).alive = true;
		(*brick).rec.width = BRICK_WIDTH;
		(*brick).rec.height = BRICK_HEIGHT;
		if(iter == 5){
			brick_y += (BRICK_HEIGHT + 5.0);
			brick_x = 15.0;
			iter = 0;
		};
		(*brick).rec.x = brick_x: f32;
		(*brick).rec.y = brick_y: f32;
		brick_x += (BRICK_WIDTH+5.0);
		iter += 1;
	};
	init_window(800, 600, window_title);
	// Game loop
	for(!window_should_close()) {
	// Update
		// Get delta time and old position
		dt = get_delta_time();
		bar_old_pos.x = bar.x;
		bar_old_pos.y = bar.y;
		proj_old_pos.x = projectile.x;
		proj_old_pos.y = projectile.y;
		// Obtain new bar position
		if(is_key_down('D')){
			bar_new_pos.x = bar_old_pos.x + (BAR_SPEED*dt);
		};
		if(is_key_down('A')){
			bar_new_pos.x = bar_old_pos.x - (BAR_SPEED*dt);
		};
		// Obtain new projectile position
		proj_new_pos.x = proj_old_pos.x + (dx*PROJ_SPEED*dt);
		proj_new_pos.y = proj_old_pos.y + (dy*PROJ_SPEED*dt);
		// Check collision between  projectile and bar
		//// Application of new position to proj and bar
		projectile.x = proj_new_pos.x;
		projectile.y = proj_new_pos.y;
		bar.x = bar_new_pos.x;
		bar.y = bar_new_pos.y;
		if(check_collision_rec(projectile, bar)) {
			dy *= -1.0;
			proj_new_pos.y = proj_old_pos.y + (dy*PROJ_SPEED*dt);
		};
		if(proj_new_pos.x<0.0 || proj_new_pos.x+30.0 > 800.0){
			dx = dx * (-1.0);
			proj_new_pos.x = proj_old_pos.x + (dx*PROJ_SPEED*dt);
		};
		if(proj_new_pos.y<0.0 || proj_new_pos.y+30.0 > 600.0){
			dy = dy * (-1.0);
			proj_new_pos.y = proj_old_pos.y + (dy*PROJ_SPEED*dt);
		};
		// Check collision with bricks in O(n)
		for(let brick &.. bricks) {
			// filter for dead bricks
			if(!(*brick).alive) {
				continue;
			};
			if(check_collision_rec(projectile, (*brick).rec)){
				dy *= -1.0;
				proj_new_pos.y = proj_old_pos.y + (dy*PROJ_SPEED*dt);
				(brick).alive = false;
			};
			  
		};
		
		projectile.x = proj_new_pos.x;
		projectile.y = proj_new_pos.y;

	//Rendering
		begin_drawing();
		clear_background(DARKGRAY);
		draw_rectangle(projectile, RAYWHITE);
		draw_rectangle(bar, BLUE);
		for(let brick .. bricks) {
			if (brick.alive) {
				draw_rectangle(brick.rec, RED);
			};
		};
		end_drawing();
	};
	close_window();
};
