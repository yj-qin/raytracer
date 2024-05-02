struct HitRecord {
  p : Point3
  normal : Vec3
  material : Material
  t : Double
  front_face : Bool
}

fn HitRecord::new(
  p : Point3,
  t : Double,
  r : Ray,
  outward_normal : Vec3,
  material : Material
) -> HitRecord {
  let front_face = r.direction().dot(outward_normal) < 0.0
  let normal = if front_face { outward_normal } else { -outward_normal }
  { p, t, front_face, normal, material }
}

trait Hittable {
  hit(Self, Ray, Interval) -> Option[HitRecord]
}

type HittableList @vec.Vec[Hittable]

fn HittableList::new() -> HittableList {
  HittableList(@vec.new())
}

fn clear(self : HittableList) -> Unit {
  self.0.clear()
}

fn add(self : HittableList, object : Hittable) -> Unit {
  self.0.push(object)
}

fn hit(self : HittableList, r : Ray, ray_t : Interval) -> Option[HitRecord] {
  let mut rec : Option[HitRecord] = None
  let mut closest_so_far = ray_t.max
  for i = 0; i < self.0.length(); i = i + 1 {
    let obj = self.0[i]
    match obj.hit(r, interval(ray_t.min, closest_so_far)) {
      Some(hrec) => {
        closest_so_far = hrec.t
        rec = Some(hrec)
      }
      _ => ()
    }
  }
  rec
}
