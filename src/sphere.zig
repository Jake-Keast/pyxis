const std = @import("std");

// Local Imports
const Vecmath = @import("vecmath.zig");
const Ray = @import("ray.zig");
const Material = @import("materials.zig");

// Vector definitions
const vec3 = std.meta.Vector(3, f64);
const point3 = vec3;

pub const sphere = struct {
    center: point3,
    radius: f64,
    mat_ptr: *Material.mat,

    pub fn hit(self: *@This(), r: *Ray.ray, t_min: f64, t_max: f64, rec: *Ray.hit_record) bool {
        // Using simplified quadratic equation when b=2h yields:
        // (-h +/- sqrt(h*h - ac)) / a
        var oc: vec3 = r.origin - self.center;
        var a: f64 = Vecmath.magnitude_squared(r.direction);
        var half_b: f64 = Vecmath.dot(oc, r.direction);
        var c = Vecmath.magnitude_squared(oc) - self.radius * self.radius;

        // find discriminant of quadratic to determine if it has real roots
        var discriminant: f64 = half_b * half_b - a * c;
        if (discriminant < 0) return false;
        var sqrt_d = @sqrt(discriminant);

        // Find the nearest root that lies in the acceptable range
        var root: f64 = (-half_b - sqrt_d) / a;
        if (root < t_min or root > t_max) {
            root = (-half_b + sqrt_d) / a;
            if (root < t_min or root > t_max) {
                return false;
            }
        }

        rec.t = root;
        rec.p = r.at(rec.t);
        rec.normal = (rec.p - self.center) / @splat(3, self.radius);
        rec.mat_ptr = self.mat_ptr;

        return true;
    }
};
