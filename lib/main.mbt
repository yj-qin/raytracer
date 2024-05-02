pub fn render_image(image_width : Int, image_height : Int) -> Unit {
  println("Start rendering...")
  // World
  let world = HittableList::new()
  let material_ground = Lambertian::new(color(0.8, 0.8, 0.0))
  let material_center = Lambertian::new(color(0.1, 0.2, 0.5))
  let material_left = Dielectric::new(1.5)
  let material_bubble = Dielectric::new(1.0 / 1.5)
  let material_right = Metal::new(color(0.8, 0.6, 0.2), fuzz=1.0)
  world.add(Sphere::new(point3(0.0, -100.5, -1.0), 100.0, material_ground))
  world.add(Sphere::new(point3(0.0, 0.0, -1.2), 0.5, material_center))
  world.add(Sphere::new(point3(-1.0, 0.0, -1.0), 0.5, material_left))
  world.add(Sphere::new(point3(-1.0, 0.0, -1.0), 0.4, material_bubble))
  world.add(Sphere::new(point3(1.0, 0.0, -1.0), 0.5, material_right))
  // let r = @math.cos(pi / 4.0)
  // let material_left = Lambertian::new(color(0.0, 0.0, 1.0))
  // let material_right = Lambertian::new(color(1.0, 0.0, 0.0))
  // world.add(Sphere::new(point3(-r, 0.0, -1.0), r, material_left))
  // world.add(Sphere::new(point3(r, 0.0, -1.0), r, material_right))
  println("image_width:\(image_width) image_height:\(image_height)")
  // Camera
  let cam = Camera::new(
    image_width,
    image_height,
    samples_per_pixel=100,
    max_depth=50,
    vfov=20.0,
    look_from=point3(-2.0, 2.0, 1.0),
  )
  cam.render(world)
  println("Done.")
}
