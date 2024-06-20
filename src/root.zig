const std = @import("std");
const expect = std.testing.expect;

const math = @import("math");

const Vec3 = math.Vec3;

pub const shapes = @import("shapes.zig");

const Box = shapes.Box;
const Sphere = shapes.Sphere;
const Plane3D = shapes.Plane3D;

pub fn sphereIntersectPlane(sphere: Sphere, plane: Plane3D) ?Sphere {
    const distance = plane.distance(sphere.origin);
    if (@abs(distance) > sphere.radius) {
        return null;
    }

    const center = sphere.origin.sub(plane.normal.scale(distance));
    return Sphere{ .origin = center, .radius = @sqrt(sphere.radius * sphere.radius - distance * distance) };
}

pub fn sphereInsideBox(box: Box, sphere: Sphere) bool {
    for (box.planes) |plane| {
        if (!sphere.insidePlane(plane)) {
            return false;
        }
    }

    return true;
}

test sphereInsideBox {
    const box = Box.fromAAB(.{ .origin = Vec3.splat(0), .extent = Vec3.splat(1) });
    const sphere = Sphere{ .origin = Vec3.splat(0.5), .radius = 0.3 };

    try expect(sphereInsideBox(box, sphere));
}

pub fn sphereIntersectBox(box: Box, sphere: Sphere) bool {
    for (0..3) |i| {
        for ([2]usize{ i, i + 3 }) |j| {
            if (sphereIntersectPlane(sphere, box.planes[j])) |intersection| blk: {
                for (box.planes, 0..) |plane, jj| {
                    if (jj != i and jj != i + 3 and plane.distance(intersection.origin) > intersection.radius) {
                        break :blk;
                    }
                }
                return true;
            }
        }
    }

    return false;
}

test sphereIntersectBox {
    const box = Box.fromAAB(.{ .origin = Vec3.splat(0), .extent = Vec3.splat(1) });
    const sphere = Sphere{ .origin = Vec3.splat(0.5), .radius = 0.8 };

    try expect(sphereIntersectBox(box, sphere));
}

pub fn sphereOutsideBox(box: Box, sphere: Sphere) bool {
    return !sphereInsideBox(box, sphere) and !sphereIntersectBox(box, sphere);
}

test sphereOutsideBox {
    const box = Box.fromAAB(.{ .origin = Vec3.splat(0), .extent = Vec3.splat(1) });
    const sphere1 = Sphere{ .origin = Vec3.splat(2), .radius = 0.8 };
    const sphere2 = Sphere{ .origin = Vec3.splat(0), .radius = 0.8 };

    try expect(sphereOutsideBox(box, sphere1));
    try expect(!sphereOutsideBox(box, sphere2));
}
