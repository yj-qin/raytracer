type Color Vec3

let intensity : Interval = interval(0.000, 0.999)

fn color(x : Double, y : Double, z : Double) -> Color {
  Color({ x, y, z })
}

fn op_add(self : Color, other : Color) -> Color {
  Color(self.0 + other.0)
}

fn op_mul(self : Color, other : Color) -> Color {
  Color(self.0 * other.0)
}

fn mul(self : Color, n : Double) -> Color {
  Color(self.0.mul(n))
}

fn linear_to_gammar(linear_commponent : Double) -> Double {
  if linear_commponent > 0.0 {
    linear_commponent.sqrt()
  } else {
    0.0
  }
}

fn rgb(self : Color) -> (Int, Int, Int) {
  let mut r = self.0.x |> linear_to_gammar()
  let mut g = self.0.y |> linear_to_gammar()
  let mut b = self.0.z |> linear_to_gammar()
  r = intensity.clamp(r) * 256.0
  g = intensity.clamp(g) * 256.0
  b = intensity.clamp(b) * 256.0
  (r.to_int(), g.to_int(), b.to_int())
}
