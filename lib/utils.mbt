let pi = 3.1415926535897932385

let infinity : Double = Double::inf(1)

let rand: @random.RandomDouble = @random.RandomDouble::new(random_seed())

fn degrees_to_radians(degrees : Double) -> Double {
  degrees * pi / 180.0
}

fn random_double() -> Double {
  rand.summon()
}

fn random_double_range(min : Double, max : Double) -> Double {
  min + (max - min) * random_double()
}

fn pow(num : Double, n : Int) -> Double {
  let mut res = 1.0
  for i = 0; i < n; i = i + 1 {
    res *= num
  }
  res
}
