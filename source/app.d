import std.stdio;

import dmech.geometry;
import dmech.rigidbody;
import dmech.world;
import dmech.shape;
import dlib.core.memory;
import dlib.math.vector;
import dlib.math.matrix;
import std.random;
import std.datetime.stopwatch : benchmark;
import core.time;
import std.getopt;

PhysicsWorld world;
Random rng;

RigidBody add_box(Vector3f pos, Vector3f size, bool static_body = false) {
	RigidBody bod;
	if (static_body) {
		bod = world.addStaticBody(pos);
	} else {
		bod = world.addDynamicBody(pos, 1f);
	}
	Geometry box = New!GeomBox(world, size);
	auto shape = world.addShapeComponent(bod, box, Vector3f(0, 0, 0), 1.0f);

	return bod;
}

RigidBody[] blocks;

void dump() {
	// log objects
	foreach (block; blocks) {
		writefln("pos: (%s), ori: (%s)", block.position, block.orientation);
	}
}

int max_collisions = 4096;
int block_count = 64;

int main(string[] args) {
	auto no_args = args.length <= 1;
	auto help = getopt(args, "col", "the maximum number of collisions in the physics engine",
			&max_collisions, "blk", "the number of test blocks to create", &block_count);

	if (no_args || help.helpWanted) {
		defaultGetoptPrinter("dmech perf test: benchmark", help.options);
		return 2;
	}

	writefln("dmech perf test (%s max collisions, %s blocks)", max_collisions, block_count);

	rng = Random(42);
	world = New!PhysicsWorld(null, 4096);

	scope (exit) {
		// clean up
		Delete(world);
	}

	auto ground = add_box(Vector3f(0, -1, 0), Vector3f(40, 1, 40), true);

	auto big_block = add_box(Vector3f(0, 8, 0), Vector3f(2, 2, 2));
	blocks ~= big_block;

	for (int i = 0; i < block_count; i++) {
		auto pos_x = uniform(-4, 4, rng);
		auto pos_y = uniform(4, 12, rng);
		auto pos_z = uniform(-4, 4, rng);

		auto blk = add_box(Vector3f(pos_x, pos_y, pos_z), Vector3f(1, 1, 1));
		blocks ~= blk;
	}

	writefln("added %s blocks", block_count);

	auto fps = 60;
	auto iterations = 10 * fps;
	double dt = 1f / fps;

	void benchmark_func() {
		world.update(dt);
	}

	writefln("running benchmark (%s iterations)", iterations);
	auto result = benchmark!(benchmark_func)(iterations);
	auto avg_time = (result[0].total!"msecs") / (cast(float) iterations);
	writefln("result: %s msec per iteration", avg_time);

	// dump();

	return 0;
}
