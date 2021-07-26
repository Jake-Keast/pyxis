const std = @import("std");

const Ray = @import("ray.zig");
const Vecmath = @import("vecmath.zig");

const vec3 = std.meta.Vector(3, f64);
const point3 = vec3;
const color = vec3;

const pow = std.math.pow;
const min = std.math.min;

const Prng = std.rand.DefaultPrng;

pub const mat_type = enum {
    LAMBERTIAN,
    METAL,
    DIELECTRIC,
};

pub const mat = union(mat_type) {
    LAMBERTIAN: lambertian,
    METAL: metal,
    DIELECTRIC: dielectric,

    pub fn scatter(self: @This(), r_in: *Ray.ray, rec: *Ray.hit_record, attenuation: *color, scattered: *Ray.ray, seed: *Prng) bool {
        switch (self) {
            .LAMBERTIAN => |*lamb| return lamb.scatter(r_in, rec, attenuation, scattered, seed),
            .METAL => |*met| return met.scatter(r_in, rec, attenuation, scattered, seed),
            .DIELECTRIC => |*di| return di.scatter(r_in, rec, attenuation, scattered, seed),
            //else => ?unreachable,
        }
    }
};

pub const lambertian = struct {
    albedo: color,

    pub fn scatter(self: @This(), r_in: *Ray.ray, rec: *Ray.hit_record, attenuation: *color, scattered: *Ray.ray, seed: *Prng) bool {
        var scatter_direction: vec3 = rec.normal + Vecmath.random_cosine_direction(seed);
        // Catch degenerate scatter direction
        if (Vecmath.near_zero(scatter_direction))
            scatter_direction = rec.normal;

        scattered.* = Ray.ray{ .origin = rec.p, .direction = scatter_direction };
        attenuation.* = self.albedo;
        return true;
    }
};

pub const metal = struct {
    albedo: color,
    f: f64,

    pub fn scatter(self: @This(), r_in: *Ray.ray, rec: *Ray.hit_record, attenuation: *color, scattered: *Ray.ray, seed: *Prng) bool {
        var reflected: vec3 = Vecmath.reflect(Vecmath.normalise(r_in.direction), rec.normal);
        var fuzz: f64 = self.f;
        if (self.f > 1.0)
            fuzz = 1.0;
        scattered.* = Ray.ray{ .origin = rec.p, .direction = reflected + @splat(3, fuzz) * Vecmath.random_cosine_direction(seed) };
        attenuation.* = self.albedo;
        return (Vecmath.dot(scattered.direction, rec.normal) > 0);
    }
};

pub const dielectric = struct {
    index_of_refraction: f64,

    pub fn scatter(self: @This(), r_in: *Ray.ray, rec: *Ray.hit_record, attenuation: *color, scattered: *Ray.ray, seed: *Prng) bool {
        attenuation.* = color{ 1.0, 1.0, 1.0 };
        var refraction_ratio: f64 = 0.0;

        var unit_direction: vec3 = Vecmath.normalise(r_in.direction);
        var cos_theta = min(Vecmath.dot(-unit_direction, rec.normal), 1.0);
        var sin_theta = @sqrt(1.0 - cos_theta * cos_theta);

        var cannot_refract: bool = refraction_ratio * sin_theta > 1.0;
        var direction: vec3 = undefined;

        if (cannot_refract or self.reflectance(cos_theta, refraction_ratio) > seed.random.float(f64)) {
            direction = Vecmath.reflect(unit_direction, rec.normal);
        } else {
            direction = Vecmath.refract(unit_direction, rec.normal, refraction_ratio);
        }

        scattered.* = Ray.ray{ .origin = rec.p, .direction = direction };
        return true;
    }
    // Schlick's approximation for reflectance
    fn reflectance(self: @This(), cosine: f64, ref_idx: f64) f64 {
        var r0 = (1 - ref_idx) / (1 + ref_idx);
        r0 = r0 * r0;
        return r0 + (1 - r0) * pow(f64, (1.0 - cosine), 5.0);
    }
};
