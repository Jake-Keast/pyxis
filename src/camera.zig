const std = @import("std");

const vec3 = std.meta.Vector(3, f64);
const point3 = vec3;

const Ray = @import("ray.zig");
const Vecmath = @import("vecmath.zig");

// Pi
const pi: f64 = 3.1415926535897932385;
const tan = std.math.tan;

const Prng = std.rand.DefaultPrng;

pub const camera = struct {
    origin: point3,
    horizontal: vec3,
    vertical: vec3,
    lower_left_corner: vec3,
    u: vec3,
    v: vec3,
    lens_radius: f64,

    pub fn init(self: *@This(), lookfrom: point3, lookat: point3, vup: vec3, vfov: f64, aspect_ratio: f64, aperture: f64, focus_dist: f64) void {
        var theta = Vecmath.degrees_to_radians(vfov);
        var h = tan(theta / 2);
        var viewport_height: f64 = 2.0 * h;
        var viewport_width: f64 = aspect_ratio * viewport_height;

        var w: vec3 = Vecmath.normalise(lookfrom - lookat);
        self.u = Vecmath.normalise(Vecmath.cross(vup, w));
        self.v = Vecmath.cross(w, self.u);

        self.origin = lookfrom;
        self.horizontal = @splat(3, focus_dist) * @splat(3, viewport_width) * self.u;
        self.vertical = @splat(3, focus_dist) * @splat(3, viewport_height) * self.v;
        self.lower_left_corner = self.origin - self.horizontal / @splat(3, @as(f64, 2.0)) - self.vertical / @splat(3, @as(f64, 2.0)) - @splat(3, focus_dist) * w;
        self.lens_radius = aperture / 2.0;
    }

    pub fn get_ray(self: *@This(), s: f64, t: f64, seed: *Prng) Ray.ray {
        var rd: vec3 = @splat(3, self.lens_radius) * Vecmath.random_in_unit_disk(seed);
        var offset: vec3 = self.u * @splat(3, rd[0]) + self.v * @splat(3, rd[1]);
        return .{
            .origin = self.origin + offset,
            .direction = self.lower_left_corner + @splat(3, s) * self.horizontal + @splat(3, t) * self.vertical - self.origin - offset,
        };
    }
};
