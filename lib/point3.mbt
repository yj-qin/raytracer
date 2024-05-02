type Point3 Vec3

fn point3(x : Double, y : Double, z : Double) -> Point3 {
  Point3(vec3(x, y, z))
}

fn op_get(self : Point3, i : Int) -> Double {
  match i {
    0 => self.0.x
    1 => self.0.y
    2 => self.0.z
    _ => abort("point3 get error")
  }
}

fn op_neg(self : Point3) -> Point3 {
  Point3(Vec3::{ x: -self.0.x, y: -self.0.y, z: -self.0.z })
}

fn op_add(self : Point3, other : Point3) -> Point3 {
  Point3(
    Vec3::{
      x: self.0.x + other.0.x,
      y: self.0.y + other.0.y,
      z: self.0.z + other.0.z,
    },
  )
}

fn op_sub(self : Point3, other : Point3) -> Point3 {
  Point3(
    Vec3::{
      x: self.0.x - other.0.x,
      y: self.0.y - other.0.y,
      z: self.0.z - other.0.z,
    },
  )
}

fn op_mul(self : Point3, other : Point3) -> Point3 {
  Point3(
    Vec3::{
      x: self.0.x * other.0.x,
      y: self.0.y * other.0.y,
      z: self.0.z * other.0.z,
    },
  )
}
