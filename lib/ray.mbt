struct Ray {
  orig : Point3
  dir : Vec3
}

fn ray(orig : Point3, dir : Vec3) -> Ray {
  { orig, dir }
}

fn origin(self : Ray) -> Point3 {
  self.orig
}

fn direction(self : Ray) -> Vec3 {
  self.dir
}

fn at(self : Ray, t : Double) -> Point3 {
  Point3(self.orig.0 + self.dir.mul(t))
}
