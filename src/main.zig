const std = @import("std");
const ArrayList = std.ArrayList;
const rand = std.rand;

// Defines the vector as 3 floating point values in 3D space, and aliases point3 and color as vec3 for readability.
const vec3 = std.meta.Vector(3, f64);
const point3 = vec3;
const color = vec3;

// Local Imports
const Camera = @import("camera.zig");
const Ray = @import("ray.zig");
const Sphere = @import("sphere.zig");
const Material = @import("materials.zig");
const Vecmath = @import("vecmath.zig");

// Image Data
const aspect_ratio: f64 = 16.0 / 9.0;
const height: u64 = 255;
const width: u64 = @floatToInt(u64, @intToFloat(f64, height) * aspect_ratio); // Calculate width from height and aspect ratio (height * aspect ratio)
const samples: u64 = 100;
const max_depth: i64 = 20;

// Memory Allocation
var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
var allocator = &arena.allocator;

// Writer
const writer = std.io.getStdOut().writer();

pub fn main() !void {
    // When this function exits, call arena.deinit()
    defer arena.deinit();

    // Prng seed
    var seed = rand.DefaultPrng.init(0);

    // Camera Setup (with test data)
    var cam: Camera.camera = undefined;
    cam.init(point3{ -2.0, 2.0, 1.0 }, point3{ 0.0, 0.0, 0.0 }, vec3{ 0.0, 1.0, 0.0 }, 90, aspect_ratio);

    // World Setup
    var world_len: u64 = 5;
    var world = ArrayList(Sphere.sphere).init(allocator);
    try world.ensureCapacity(world_len);
    //   Adding some spheres to the world
    var material_ground = Material.mat{ .LAMBERTIAN = Material.lambertian{ .albedo = color{ 0.8, 0.8, 0.0 } } };
    var material_center = Material.mat{ .LAMBERTIAN = Material.lambertian{ .albedo = color{ 0.1, 0.2, 0.5 } } };
    var material_left = Material.mat{ .DIELECTRIC = Material.dielectric{ .index_of_refraction = 1.5 } };
    var material_right = Material.mat{ .METAL = Material.metal{ .albedo = color{ 0.8, 0.6, 0.2 }, .f = 0.0 } };
    var ground: Sphere.sphere = .{
        .center = .{ 0.0, -100.5, -1.0 },
        .radius = 100.0,
        .mat_ptr = &material_ground,
    };
    var center: Sphere.sphere = .{
        .center = .{ 0.0, 0.0, -1.0 },
        .radius = 0.5,
        .mat_ptr = &material_center,
    };
    var left1: Sphere.sphere = .{
        .center = .{ -1.0, 0.0, -1.0 },
        .radius = 0.5,
        .mat_ptr = &material_left,
    };
    var left2: Sphere.sphere = .{
        .center = .{ -1.0, 0.0, -1.0 },
        .radius = -0.45,
        .mat_ptr = &material_left,
    };
    var right: Sphere.sphere = .{
        .center = .{ 1.0, 0.0, -1.0 },
        .radius = 0.5,
        .mat_ptr = &material_right,
    };
    try world.append(ground);
    try world.append(center);
    try world.append(left1);
    try world.append(left2);
    try world.append(right);

    // Write PPM header
    try writer.print("P3\n{} {}\n255\n", .{ width, height });

    // Render Loop
    var j: i64 = height - 1;
    while (j >= 0) : (j -= 1) {
        var i: i64 = 0;
        while (i < width) : (i += 1) {
            var sample: u64 = 0;
            var color_ac: color = .{ 0.0, 0.0, 0.0 };
            while (sample < samples) : (sample += 1) {
                var U: f64 = (@intToFloat(f64, i) + seed.random.float(f64)) / @intToFloat(f64, width - 1);
                var V: f64 = (@intToFloat(f64, j) + seed.random.float(f64)) / @intToFloat(f64, height - 1);
                var r: Ray.ray = cam.get_ray(U, V);
                color_ac += Ray.ray_color(&r, world, &seed, max_depth);
            }
            color_ac = color_ac * @splat(3, @as(f64, (1.0 / @intToFloat(f64, samples))));
            try write_pixel(color_ac);
        }
    }
}

// Write color data for each pixel to standard output
fn write_pixel(c: color) !void {
    try writer.print("{} {} {}\n", .{
        @floatToInt(i64, 255.999 * @sqrt(c[0])),
        @floatToInt(i64, 255.999 * @sqrt(c[1])),
        @floatToInt(i64, 255.999 * @sqrt(c[2])),
    });
}
