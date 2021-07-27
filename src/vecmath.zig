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

pub fn random_cosine_direction(seed: *Prng) vec3 {
    var r1: f64 = seed.random.float(f64);
    var r2: f64 = seed.random.float(f64);
    var z: f64 = @sqrt(1 - r2);

    var phi: f64 = 2 * pi * r1;
    var x: f64 = @cos(phi) * @sqrt(r2);
    var y: f64 = @sin(phi) * @sqrt(r2);

    return vec3{ x, y, z };
}

pub fn random_in_hemisphere(normal: vec3, seed: *Prng) vec3 {
    var in_unit_sphere: vec3 = random_cosine_direction(seed) * @splat(3, @as(f64, @sqrt(seed.random.float(f64))));
    if (dot(in_unit_sphere, normal) > 0.0) { // In the same hemisphere as the normal
        return in_unit_sphere;
    } else {
        return -in_unit_sphere;
    }
}

// min + (max-min)*seed.random.float(f64)

pub fn random_in_unit_disk(seed: *Prng) vec3 {
    while (true) {
        var p = vec3{ -1.0 + seed.random.float(f64) * 2.0, -1.0 + seed.random.float(f64) * 2.0, 0.0 };
        if (magnitude_squared(p) >= 1) continue;
        return p;
    }
}

pub fn near_zero(v: vec3) bool {
    const s: f64 = 1e-8;
    return (abs(v[0]) < s) and (abs(v[1]) < s) and (abs(v[2]) < s);
}

pub fn degrees_to_radians(angle: f64) f64 {
    return angle * (pi / 180.0);
}

pub fn reflect(v: vec3, n: vec3) vec3 {
    return v - @splat(3, @as(f64, 2)) * @splat(3, dot(v, n)) * n;
}

pub fn refract(uv: vec3, n: vec3, etai_over_etat: f64) vec3 {
    var cos_theta: f64 = min(dot(-uv, n), 1.0);
    var r_out_perp: vec3 = @splat(3, etai_over_etat) * (uv - @splat(3, cos_theta) * n);
    var r_out_parallel: vec3 = @splat(3, -@sqrt(abs(1.0 - magnitude_squared(r_out_perp)))) * n;
    return r_out_perp + r_out_parallel;
}
