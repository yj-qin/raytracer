struct Camera {
  image_width : Int // Rendered image width
  image_height : Int // Rendered image height
  center : Point3 // Camera center
  pixel_00_loc : Point3 // Location of pixel 0, 0
  pixel_delta_u : Vec3 // Offset to pixel to the right
  pixel_delta_v : Vec3 // Offset to pixel below
  samples_per_pixel : Int // Count of random samples for each pixel
  pixel_samples_scale : Double // Color scale factor for a sum of pixel samples
  max_depth : Int // Maximum number of ray bounces into scene
  vfov : Double // Vertical view angle (field of view)
  look_from : Point3 // Point camera is looking from
  look_at : Point3 // Point camera is looking at
  vup : Vec3 // Camera-relative "up" direction
  // Camera frame basis vectors
  u : Vec3
  v : Vec3
  w : Vec3
  defocus_angle : Double // Variation angle of rays through each pixel
  focus_dist : Double // Distance from camera lookfrom point to plane of perfect focus
  defocus_disk_u : Vec3 // Defocus disk horizontal radius
  defocus_disk_v : Vec3 // Defocus disk vertical radius
}

fn Camera::new(
  image_width : Int,
  image_height : Int,
  ~samples_per_pixel : Int = 10,
  ~max_depth : Int = 10,
  ~vfov : Double = 90.0,
  ~look_from : Point3 = point3(0.0, 0.0, 0.0),
  ~look_at : Point3 = point3(0.0, 0.0, -1.0),
  ~vup : Vec3 = vec3(0.0, 1.0, 0.0),
  ~defocus_angle : Double = 0.0,
  ~focus_dist : Double = 10.0
) -> Camera {
  // Determine viewport dimensions.
  let theta = degrees_to_radians(vfov)
  let h = @math.tan(theta / 2.0)
  let viewport_height = 2.0 * h * focus_dist
  let viewport_width = viewport_height * (image_width.to_double() / image_height.to_double())
  // Calculate the u,v,w unit basis vectors for the camera coordinate frame.
  let w = unit_vector((look_from - look_at).0)
  let u = unit_vector(cross(vup, w))
  let v = cross(w, u)
  // Calculate the vectors across the horizontal and down the vertical viewport edges.
  let viewport_u = u.mul(viewport_width)
  let viewport_v = -v.mul(viewport_height)
  // Calculate the horizontal and vertical delta vectors from pixel to pixel.
  let pixel_delta_u = viewport_u.div(image_width.to_double())
  let pixel_delta_v = viewport_v.div(image_height.to_double())
  // Calculate the location of the upper left pixel.
  let viewport_upper_left = look_from.0 - w.mul(focus_dist) - viewport_u.div(
      2.0,
    ) - viewport_v.div(2.0)
  let pixel_00_loc : Point3 = Point3(
    viewport_upper_left + (pixel_delta_u + pixel_delta_v).mul(0.5),
  )
  // Calculate the camera defocus disk basis vectors.
  let defocus_radius = focus_dist * @math.tan(
      degrees_to_radians(defocus_angle / 2.0),
    )
  let defocus_disk_u = u.mul(defocus_radius)
  let defocus_disk_v = v.mul(defocus_radius)
  let pixel_samples_scale = 1.0 / samples_per_pixel.to_double()
  {
    image_width,
    image_height,
    center: look_from,
    pixel_00_loc,
    pixel_delta_u,
    pixel_delta_v,
    samples_per_pixel,
    pixel_samples_scale,
    max_depth,
    vfov,
    look_from,
    look_at,
    vup,
    u,
    v,
    w,
    defocus_angle,
    focus_dist,
    defocus_disk_u,
    defocus_disk_v,
  }
}

fn render(self : Camera, world : Hittable) -> Unit {
  for j = 0; j < self.image_height; j = j + 1 {
    println("Scanlines remaining: " + (self.image_height - j).to_string())
    for i = 0; i < self.image_width; i = i + 1 {
      self.render_pixel(world, i, j)
    }
  }
}

fn render_cols(
  self : Camera,
  world : Hittable,
  start : Int,
  end : Int
) -> Unit {
  for j = 0; j < self.image_height; j = j + 1 {
    for i = start; i < end; i = i + 1 {
      self.render_pixel(world, i, j)
    }
  }
}

fn render_pixel(self : Camera, world : Hittable, x : Int, y : Int) -> Unit {
  let mut pixel_color = color(0.0, 0.0, 0.0)
  for s = 0; s < self.samples_per_pixel; s = s + 1 {
    let r = self.get_ray(x, y)
    pixel_color += ray_color(r, self.max_depth, world)
  }
  let n = (y * self.image_width + x) * 4
  pixel_color = pixel_color.mul(self.pixel_samples_scale)
  let (r, g, b) = pixel_color.rgb()
  set_pixel(n, r, g, b, 255)
  incr_progress()
}

// Construct a camera ray originating from the origin and directed at randomly sampled
// point around the pixel location i, j.
fn get_ray(self : Camera, i : Int, j : Int) -> Ray {
  let offset = sample_square()
  let pixel_sample = self.pixel_00_loc.0 + self.pixel_delta_u.mul(
      i.to_double() + offset.x(),
    ) + self.pixel_delta_v.mul(j.to_double() + offset.y())
  let orig = if self.defocus_angle <= 0.0 {
    self.center
  } else {
    self.defocus_disk_sample()
  }
  let dir = pixel_sample - orig.0
  ray(orig, dir)
}

// Returns a random point in the camera defocus disk.
fn defocus_disk_sample(self : Camera) -> Point3 {
  let p = random_in_unit_disk()
  Point3(
    self.center.0 + self.defocus_disk_u.mul(p[0]) + self.defocus_disk_v.mul(
      p[1],
    ),
  )
}

// Returns the vector to a random point in the [-.5,-.5]-[+.5,+.5] unit square.
fn sample_square() -> Vec3 {
  vec3(random_double() - 0.5, random_double() - 0.5, 0.0)
}

fn ray_color(r : Ray, depth : Int, world : Hittable) -> Color {
  if depth < 0 {
    return color(0.0, 0.0, 0.0)
  }
  match world.hit(r, interval(0.001, infinity)) {
    Some(rec) => {
      match rec.material.scatter(r, rec) {
        Some((attenuation, scattered)) =>
          return attenuation * ray_color(scattered, depth - 1, world)
        _ => return color(0.0, 0.0, 0.0)
      }
      let direction = rec.normal + random_unit_vector()
      return ray_color(ray(rec.p, direction), depth - 1, world).mul(0.5)
    }
    _ => ()
  }
  let unit_direction = r.direction().unit_vector()
  let a = 0.5 * (unit_direction.y() + 1.0)
  Color(vec3(1.0, 1.0, 1.0).mul(1.0 - a) + vec3(0.5, 0.7, 1.0).mul(a))
}
