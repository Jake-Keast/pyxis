const std = @import("std");
const ArrayList = std.ArrayList;
const rand = std.rand;

// Defines the vector as 3 floating point values in 3D space, and aliases point3 and color as vec3 for readability.
const vec3 = std.meta.Vector(3, f64);
const point3 = vec3;
const color = vec3;

// Memory Allocation
var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
var allocator = &arena.allocator;

// Image Data
const aspect_ratio: f64 = 16.0 / 9.0;
const height: u64 = 255;
const width: u64 = @floatToInt(u64, @intToFloat(f64, height) * aspect_ratio); // Calculate width from height and aspect ratio (height * aspect ratio)

// Writer
const writer = std.io.getStdOut().writer();

pub fn main() !void {
    // When this function exits, call arena.deinit()
    defer arena.deinit();
    // Write PPM header
    try writer.print("P3\n{} {}\n255\n", .{ width, height });

    var j: i64 = height - 1;
    while (j >= 0) : (j -= 1) {
        var i: i64 = 0;
        while (i < width) : (i += 1) {
            var r: f64 = 1.0;
            var g: f64 = 0.0;
            var b: f64 = 0.0;
            var c: color = .{ r, g, b };
            try write_pixel(c);
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
