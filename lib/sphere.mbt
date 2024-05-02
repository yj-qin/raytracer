struct Sphere {
  center : Point3
  radius : Double
  material : Material
}

fn Sphere::new(center : Point3, radius : Double, material : Material) -> Sphere {
  { center, radius, material }
}

fn hit(self : Sphere, r : Ray, ray_t : Interval) -> Option[HitRecord] {
  let oc = self.center.0 - r.origin().0
  let a = r.direction().length_squared()
  let h = r.direction().dot(oc)
  let c = oc.length_squared() - self.radius * self.radius
  let discriminant = h * h - a * c
  if discriminant < 0.0 {
    return None
  }
  let sqrtd = discriminant.sqrt()
  // Find the nearest root that lies in the acceptable range.
  let mut root = (h - sqrtd) / a
  if ray_t.surrounds(root).not() {
    root = (h + sqrtd) / a
    if ray_t.surrounds(root).not() {
      return None
    }
  }
  let p = r.at(root)
  let outward_normal = (p.0 - self.center.0).div(self.radius)
  let rec = HitRecord::new(p, root, r, outward_normal, self.material)
  Some(rec)
}
