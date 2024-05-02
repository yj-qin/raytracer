struct Interval {
  min : Double
  max : Double
}

fn interval(min : Double, max : Double) -> Interval {
  { min, max }
}

fn Interval::default() -> Interval {
  { min: -infinity, max: infinity }
}

fn Interval::empty() -> Interval {
  { min: infinity, max: -infinity }
}

fn Interval::universe() -> Interval {
  { min: -infinity, max: infinity }
}

fn size(self : Interval) -> Double {
  self.max - self.min
}

fn contains(self : Interval, x : Double) -> Bool {
  self.min <= x && x <= self.max
}

fn surrounds(self : Interval, x : Double) -> Bool {
  self.min < x && x < self.max
}

fn clamp(self : Interval, x : Double) -> Double {
  if x < self.min {
    self.min
  } else if x > self.max {
    self.max
  } else {
    x
  }
}
