struct Vec3 {
  x : Double
  y : Double
  z : Double
}

fn vec3(x : Double, y : Double, z : Double) -> Vec3 {
  { x, y, z }
}

fn Vec3::random() -> Vec3 {
  { x: random_double(), y: random_double(), z: random_double() }
}

fn Vec3::random_range(min : Double, max : Double) -> Vec3 {
  {
    x: random_double_range(min, max),
    y: random_double_range(min, max),
    z: random_double_range(min, max),
  }
}

fn random_in_unit_sphere() -> Vec3 {
  while true {
    let p = Vec3::random_range(-1.0, 1.0)
    if p.length_squared() < 1.0 {
      return p
    }
  } else {
    vec3(0.0, 0.0, 0.0)
  }
}

fn random_unit_vector() -> Vec3 {
  unit_vector(random_in_unit_sphere())
}

fn random_in_unit_disk() -> Vec3 {
  while true {
    let p = vec3(
      random_double_range(-1.0, 1.0),
      random_double_range(-1.0, 1.0),
      0.0,
    )
    if p.length_squared() < 1.0 {
      return p
    }
  } else {
    vec3(0.0, 0.0, 0.0)
  }
}

fn reflect(v : Vec3, n : Vec3) -> Vec3 {
  v - n.mul(2.0 * v.dot(n))
}

fn refract(uv : Vec3, n : Vec3, etai_over_etat : Double) -> Vec3 {
  let cos_theta = @math.minimum(dot(-uv, n), 1.0)
  let r_out_perp = (uv + n.mul(cos_theta)).mul(etai_over_etat)
  let r_out_parallel = n.mul(-(1.0 - r_out_perp.length_squared()).abs().sqrt())
  r_out_perp + r_out_parallel
}

fn x(self : Vec3) -> Double {
  self.x
}

fn y(self : Vec3) -> Double {
  self.y
}

fn z(self : Vec3) -> Double {
  self.z
}

fn op_get(self : Vec3, i : Int) -> Double {
  match i {
    0 => self.x
    1 => self.y
    2 => self.z
    _ => abort("vec3 get error")
  }
}

fn op_neg(self : Vec3) -> Vec3 {
  Vec3::{ x: -self.x, y: -self.y, z: -self.z }
}

fn op_add(self : Vec3, other : Vec3) -> Vec3 {
  Vec3::{ x: self.x + other.x, y: self.y + other.y, z: self.z + other.z }
}

fn op_sub(self : Vec3, other : Vec3) -> Vec3 {
  Vec3::{ x: self.x - other.x, y: self.y - other.y, z: self.z - other.z }
}

fn op_mul(self : Vec3, other : Vec3) -> Vec3 {
  Vec3::{ x: self.x * other.x, y: self.y * other.y, z: self.z * other.z }
}

fn mul(self : Vec3, t : Double) -> Vec3 {
  Vec3::{ x: self.x * t, y: self.y * t, z: self.z * t }
}

fn div(self : Vec3, t : Double) -> Vec3 {
  self.mul(1.0 / t)
}

fn dot(self : Vec3, other : Vec3) -> Double {
  self.x * other.x + self.y * other.y + self.z * other.z
}

fn cross(self : Vec3, other : Vec3) -> Vec3 {
  Vec3::{
    x: self.y * other.z - self.z * other.y,
    y: self.z * other.x - self.x * other.z,
    z: self.x * other.y - self.y * other.x,
  }
}

fn unit_vector(self : Vec3) -> Vec3 {
  self.div(self.length())
}

fn length(self : Vec3) -> Double {
  self.length_squared().sqrt()
}

fn length_squared(self : Vec3) -> Double {
  self.x * self.x + self.y * self.y + self.z * self.z
}

fn near_zero(self : Vec3) -> Bool {
  let s = 1.0e-8
  self.x.abs() < s && self.y.abs() < s && self.z.abs() < s
}
