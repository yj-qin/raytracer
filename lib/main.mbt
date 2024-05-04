pub fn render_image(image_width : Int, image_height : Int) -> Unit {
  println("Start rendering...")
  let world = create_world()
  let cam = create_camera(image_width, image_height)
  cam.render(world)
  println("Done.")
}

pub fn partial_render_image(image_width: Int, image_height: Int, start: Int, end: Int) -> Unit {
  println("Start partial rendering... [\(start)-\(end)]")
  let world = create_world()
  let cam = create_camera(image_width, image_height)
  cam.render_cols(world, start, end)
  println("Partial rendering done. [\(start)-\(end)]")
}

fn create_camera(image_width: Int, image_height: Int) -> Camera {
  // Camera
  Camera::new(
    image_width,
    image_height,
    samples_per_pixel=500,
    max_depth=50,
    vfov=20.0,
    look_from=point3(13.0, 2.0, 3.0),
    look_at=point3(0.0, 0.0, 0.0),
    vup=vec3(0.0, 1.0, 0.0),
    defocus_angle=0.6,
    focus_dist=10.0,
  )
}

fn create_world() -> HittableList {
  // World
  let world = HittableList::new()
  let ground_material = Lambertian::new(color(0.5, 0.5, 0.5))
  world.add(Sphere::new(point3(0.0, -1000.0, 0.0), 1000.0, ground_material))
  // Random small spheres
  for a = -11; a < 11; a = a + 1 {
    for b = -11; b < 11; b = b + 1 {
      let choose_mat = random_double()
      let center = point3(
        a.to_double() + 0.9 * random_double(),
        0.2,
        b.to_double() + 0.9 * random_double(),
      )
      if (center - point3(4.0, 0.2, 0.0)).0.length() > 0.9 {
        if choose_mat < 0.8 {
          // diffuse
          let albedo = random_color() * random_color()
          let sphere_material = Lambertian::new(albedo)
          world.add(Sphere::new(center, 0.2, sphere_material))
        } else if choose_mat < 0.95 {
          // metal
          let albedo = random_color_range(0.5, 1.0)
          let fuzz = random_double_range(0.0, 0.5)
          let sphere_material = Metal::new(albedo, ~fuzz)
          world.add(Sphere::new(center, 0.2, sphere_material))
        } else {
          // glass
          let sphere_material = Dielectric::new(1.5)
          world.add(Sphere::new(center, 0.2, sphere_material))
        }
      }
    }
  }
  // Three big spheres
  let material1 = Dielectric::new(1.5)
  world.add(Sphere::new(point3(0.0, 1.0, 0.0), 1.0, material1))
  let material2 = Lambertian::new(color(0.4, 0.2, 0.1))
  world.add(Sphere::new(point3(-4.0, 1.0, 0.0), 1.0, material2))
  let material3 = Metal::new(color(0.7, 0.6, 0.5))
  world.add(Sphere::new(point3(4.0, 1.0, 0.0), 1.0, material3))
  world
}
