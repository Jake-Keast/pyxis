const std = @import("std");
const vec3 = std.meta.Vector(3, f64);

const abs = std.math.absFloat;
const min = std.math.min;

const Prng = std.rand.DefaultPrng;
const pi: f64 = 3.1415926535897932385;

pub fn magnitude(v: vec3) f64 {
    return @sqrt(magnitude_squared(v));
}

pub fn magnitude_squared(v: vec3) f64 {
    return v[0] * v[0] + v[1] * v[1] + v[2] * v[2];
}

pub fn dot(u: vec3, v: vec3) f64 {
    return u[0] * v[0] + u[1] * v[1] + u[2] * v[2];
}

pub fn cross(u: vec3, v: vec3) vec3 {
    return .{
        (u[1] * v[2] - u[2] * v[1]),
        (u[2] * v[0] - u[0] * v[2]),
        (u[0] * v[1] - u[1] * v[0]),
    };
}

pub fn normalise(v: vec3) vec3 {
    return v / @splat(3, magnitude(v));
}

pub fn random(s: u64) vec3 {
    var seed = rand.DefaultPrng.init(s);
    return vec3{ seed.random.float(f64), seed.random.float(f64), seed.random.float(f64) };
}

pub fn near_zero(v: vec3) bool {
    const s: f64 = 1e-8;
    return (abs(v[0]) < s) and (abs(v[1]) < s) and (abs(v[2]) < s);
}

pub fn degrees_to_radians(angle: f64) f64 {
    return angle * (pi / 180.0);
}
