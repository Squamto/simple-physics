const std = @import("std");
const math = @import("math");
const expect = std.testing.expect;

const Vec2 = math.Vec2;
const Vec3 = math.Vec3;

/// Origin is the bottom left (-x, -y)
pub const Plane2D = struct {
    origin: Vec2,
    extent: Vec2,

    pub fn contains(self: Plane2D, point: Vec2) bool {
        return @reduce(.And, point.data >= self.origin.data) and @reduce(.And, point.data <= self.extent.data);
    }

    test contains {
        const plane = Plane2D{
            .origin = Vec2.splat(0),
            .extent = Vec2.splat(1),
        };

        const p1 = Vec2.splat(0.5);
        const p2 = Vec2.splat(-1);

        try expect(plane.contains(p1));
        try expect(!plane.contains(p2));
    }
};

pub const Plane3D = struct {
    origin: Vec3,
    normal: Vec3,

    pub fn distance(self: Plane3D, point: Vec3) f32 {
        return self.normal.dot(point.sub(self.origin));
    }
};

pub const Box = struct {
    planes: [6]Plane3D,

    pub fn fromAAB(other: AxisAlignedBox) Box {
        std.debug.assert(other.extent.x() >= 0 and other.extent.y() >= 0 and other.extent.z() >= 0);
        const C2 = other.origin.add(other.extent);
        return .{
            .planes = .{
                .{ .origin = other.origin, .normal = .{ .data = .{ -1.0, 0, 0 } } },
                .{ .origin = other.origin, .normal = .{ .data = .{ 0, -1.0, 0 } } },
                .{ .origin = other.origin, .normal = .{ .data = .{ 0, 0, -1.0 } } },
                .{ .origin = C2, .normal = .{ .data = .{ 1.0, 0, 0 } } },
                .{ .origin = C2, .normal = .{ .data = .{ 0, 1.0, 0 } } },
                .{ .origin = C2, .normal = .{ .data = .{ 0, 0, 1.0 } } },
            },
        };
    }

    pub fn translate(self: Box, translation: Vec3) Box {
        var result = self;
        for (&result.planes) |*plane|
            plane.origin = plane.origin.add(translation);

        return result;
    }

    test translate {
        var box = Box.fromAAB(.{ .origin = Vec3.splat(0), .extent = Vec3.splat(1) });
        box = box.translate(Vec3.splat(1));

        try expect(@reduce(.And, box.planes[0].origin.data == Vec3.splat(1).data));
    }
};

pub const AxisAlignedBox = struct {
    origin: Vec3,
    extent: Vec3,

    pub fn contains(self: AxisAlignedBox, point: Vec3) bool {
        return @reduce(.And, point.data >= self.origin.data) and @reduce(.And, point.data <= self.extent.data);
    }

    test contains {
        const box = AxisAlignedBox{
            .origin = Vec3.splat(0),
            .extent = Vec3.splat(1),
        };

        const p1 = Vec3.splat(0.5);
        const p2 = Vec3.splat(-1);

        try expect(box.contains(p1));
        try expect(!box.contains(p2));
    }
};

pub const Sphere = struct {
    origin: Vec3,
    radius: f32,

    pub fn translate(self: Sphere, translation: Vec3) Sphere {
        return .{
            .origin = self.origin.add(translation),
            .radius = self.radius,
        };
    }

    pub fn insidePlane(self: Sphere, plane: Plane3D) bool {
        return plane.distance(self.origin) < -self.radius;
    }

    pub fn outsidePlane(self: Sphere, plane: Plane3D) bool {
        return plane.distance(self.origin) > self.radius;
    }
    pub fn contains(self: Sphere, point: Vec3) bool {
        return self.origin.sub(point).lenSq() < self.radius * self.radius;
    }

    test contains {
        const sphere = Sphere{
            .origin = Vec3.splat(0),
            .radius = 1.0,
        };

        const p1 = Vec3{ .data = .{ 0.5, 0, 0 } };
        const p2 = Vec3.splat(2);

        try expect(sphere.contains(p1));
        try expect(!sphere.contains(p2));
    }
};
