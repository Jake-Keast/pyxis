const std = @import("std");

const vec3 = std.meta.Vector(3, f64);
const point3 = vec3;

const Ray = @import("ray.zig");
const Vecmath = @import("vecmath.zig");

// Pi
const pi: f64 = 3.1415926535897932385;
const tan = std.math.tan;

pub const camera = struct {
    origin: point3,
    horizontal: vec3,
    vertical: vec3,
    lower_left_corner: vec3,

    pub fn init(self: *@This(), lookfrom: point3, lookat: point3, vup: vec3, vfov: f64, aspect_ratio: f64) void {
        var theta = Vecmath.degrees_to_radians(vfov);
        var h = tan(theta / 2);
        var viewport_height: f64 = 2.0 * h;
        var viewport_width: f64 = aspect_ratio * viewport_height;

        var w: vec3 = Vecmath.normalise(lookfrom - lookat);
        var u: vec3 = Vecmath.normalise(Vecmath.cross(vup, w));
        var v: vec3 = Vecmath.cross(w, u);

        self.origin = lookfrom;
        self.horizontal = @splat(3, viewport_width) * u;
        self.vertical = @splat(3, viewport_height) * v;
        self.lower_left_corner = self.origin - self.horizontal / @splat(3, @as(f64, 2.0)) - self.vertical / @splat(3, @as(f64, 2.0)) - w;
    }

    pub fn get_ray(self: *@This(), s: f64, t: f64) Ray.ray {
        return .{
            .origin = self.origin,
            .direction = self.lower_left_corner + @splat(3, s) * self.horizontal + @splat(3, t) * self.vertical - self.origin,
        };
    }
};
