const std = @import("std");
const ArrayList = std.ArrayList;

// Vector Definitions
const vec3 = std.meta.Vector(3, f64);
const point3 = vec3;
const color = vec3;

// Define the Prng seed in order to reference it as a pointer type
const Prng = std.rand.DefaultPrng;

// Local Imports
const Vecmath = @import("vecmath.zig");
const Sphere = @import("sphere.zig");
const Material = @import("materials.zig");

// Define "infinity" for use as an upper limit
const infinity = std.math.inf_f64;

// Defines the ray struct.
// A ray is defined as a direction vector from a fixed origin
pub const ray = struct {
    origin: point3,
    direction: vec3,

    pub fn at(self: *@This(), t: f64) point3 {
        return self.origin + @splat(3, t) * self.direction;
    }
};

pub const hit_record = struct {
    p: point3,
    normal: vec3,
    t: f64,
    front_face: bool,
    mat_ptr: *Material.mat,

    pub fn set_face_normal(self: *@This(), r: *ray, outward_normal: vec3) void {
        self.front_face = (Vecmath.dot(r.direction, outward_normal) < 0);
        if (self.front_face) {
            self.normal = outward_normal;
        } else {
            self.normal = -outward_normal;
        }
    }
};

pub fn ray_color(r: *ray, world: ArrayList(Sphere.sphere), seed: *Prng, depth: i64) color {
    var rec: hit_record = undefined;

    // If the max recursion depth has been reached, return zeroed color data (since final color is cumulative)
    if (depth <= 0)
        return color{ 0.0, 0.0, 0.0 };

    if (hit(r, 0.001, infinity, &rec, world)) {
        var scattered: ray = undefined;
        var attenuation: color = undefined;
        if (rec.mat_ptr.scatter(r, &rec, &attenuation, &scattered, seed)) {
            return attenuation * ray_color(&scattered, world, seed, depth - 1);
        }

        return color{ 0.0, 0.0, 0.0 };
    }

    var unit_direction: vec3 = Vecmath.normalise(r.direction);
    var t: f64 = 0.5 * (unit_direction[1] + 1.0);
    return @splat(3, (1.0 - t)) * color{ 1.0, 1.0, 1.0 } + @splat(3, t) * color{ 0.5, 0.7, 1.0 };
}

fn hit(r: *ray, t_min: f64, t_max: f64, rec: *hit_record, world: ArrayList(Sphere.sphere)) bool {
    var temp_rec: hit_record = undefined;
    var hit_anything: bool = false;
    var closest_so_far: f64 = t_max;

    for (world.items) |_, i| {
        if (world.items[i].hit(r, t_min, closest_so_far, &temp_rec)) {
            hit_anything = true;
            closest_so_far = temp_rec.t;
            rec.* = temp_rec;
        }
    }

    return hit_anything;
}
