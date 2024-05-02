struct Camera {
  // Rendered image width
  image_width : Int
  // Rendered image height
  image_height : Int
  // Camera center
  center : Point3
  // Location of pixel 0, 0
  pixel_00_loc : Point3
  // Offset to pixel to the right
  pixel_delta_u : Vec3
  // Offset to pixel below
  pixel_delta_v : Vec3
  // Count of random samples for each pixel
  samples_per_pixel : Int
  // Color scale factor for a sum of pixel samples
  pixel_samples_scale : Double
  // Maximum number of ray bounces into scene
  max_depth : Int
  // Vertical view angle (field of view)
  vfov : Double
  // Point camera is looking from
  look_from : Point3
  // Point camera is looking at
  look_at : Point3
  // Camera-relative "up" direction
  vup : Vec3
  // Camera frame basis vectors
  u : Vec3
  v : Vec3
  w : Vec3
}

fn Camera::new(
  image_width : Int,
  image_height : Int,
  ~samples_per_pixel : Int = 10,
  ~max_depth : Int = 10,
  ~vfov : Double = 90.0,
  ~look_from : Point3 = point3(0.0, 0.0, 0.0),
  ~look_at : Point3 = point3(0.0, 0.0, -1.0),
  ~vup : Vec3 = vec3(0.0, 1.0, 0.0)
) -> Camera {
  // Determine viewport dimensions.
  let focal_len = (look_from - look_at).0.length()
  let theta = degrees_to_radians(vfov)
  let h = @math.tan(theta / 2.0)
  let viewport_height = 2.0 * h * focal_len
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
  let viewport_upper_left = look_from.0 - w.mul(focal_len) - viewport_u.div(2.0) -
    viewport_v.div(2.0)
  let pixel_00_loc : Point3 = Point3(
    viewport_upper_left + (pixel_delta_u + pixel_delta_v).mul(0.5),
  )
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
  }
}

fn render(self : Camera, world : Hittable) -> Unit {
  for j = 0; j < self.image_height; j = j + 1 {
    println("Scanlines remaining: " + (self.image_height - j).to_string())
    set_progress(j.to_double() / self.image_height.to_double() * 100.0)
    for i = 0; i < self.image_width; i = i + 1 {
      let mut pixel_color = color(0.0, 0.0, 0.0)
      for s = 0; s < self.samples_per_pixel; s = s + 1 {
        let r = self.get_ray(i, j)
        pixel_color += ray_color(r, self.max_depth, world)
      }
      let x = (j * self.image_width + i) * 4
      pixel_color = pixel_color.mul(self.pixel_samples_scale)
      let (r, g, b) = pixel_color.rgb()
      set_pixel(x, r, g, b, 255)
    }
  }
}

// Construct a camera ray originating from the origin and directed at randomly sampled
// point around the pixel location i, j.
fn get_ray(self : Camera, i : Int, j : Int) -> Ray {
  let offset = sample_square()
  let pixel_sample = self.pixel_00_loc.0 + self.pixel_delta_u.mul(
      i.to_double() + offset.x(),
    ) + self.pixel_delta_v.mul(j.to_double() + offset.y())
  let orig = self.center
  let dir = pixel_sample - orig.0
  ray(orig, dir)
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
