trait Material {
  scatter(Self, Ray, HitRecord) -> Option[(Color, Ray)]
}

struct Lambertian {
  albedo : Color
}

fn Lambertian::new(albedo : Color) -> Lambertian {
  Lambertian::{ albedo, }
}

fn scatter(
  self : Lambertian,
  _r_in : Ray,
  rec : HitRecord
) -> Option[(Color, Ray)] {
  let mut scatter_direction = rec.normal + random_unit_vector()
  // Catch degenerate scatter direction
  if scatter_direction.near_zero() {
    scatter_direction = rec.normal
  }
  let scattered = ray(rec.p, scatter_direction)
  let attenuation = self.albedo
  Some((attenuation, scattered))
}

struct Metal {
  albedo : Color
  fuzz : Double
}

fn Metal::new(albedo : Color, ~fuzz : Double = 0.0) -> Metal {
  let fuzz = if fuzz < 1.0 { fuzz } else { 1.0 }
  Metal::{ albedo, fuzz }
}

fn scatter(self : Metal, r_in : Ray, rec : HitRecord) -> Option[(Color, Ray)] {
  let mut reflected = reflect(r_in.direction(), rec.normal)
  reflected = reflected.unit_vector() + random_unit_vector().mul(self.fuzz)
  let scattered = ray(rec.p, reflected)
  let attenuation = self.albedo
  if scattered.direction().dot(rec.normal) > 0.0 {
    Some((attenuation, scattered))
  } else {
    None
  }
}

struct Dielectric {
  // Refractive index in vacuum or air, or the ratio of the material's refractive index over
  // the refractive index of the enclosing media
  refraction_index : Double
}

fn Dielectric::new(refraction_index : Double) -> Dielectric {
  { refraction_index, }
}

fn scatter(
  self : Dielectric,
  r_in : Ray,
  rec : HitRecord
) -> Option[(Color, Ray)] {
  let attenuation = color(1.0, 1.0, 1.0)
  let ri = if rec.front_face {
    1.0 / self.refraction_index
  } else {
    self.refraction_index
  }
  let unit_direction = r_in.direction().unit_vector()
  let cos_theta = @math.minimum(dot(-unit_direction, rec.normal), 1.0)
  let sin_theta = sqrt(1.0 - cos_theta * cos_theta)
  let cannot_refract = ri * sin_theta > 1.0
  let direction = if cannot_refract || reflectance(cos_theta, ri) > random_double() {
    reflect(unit_direction, rec.normal)
  } else {
    refract(unit_direction, rec.normal, ri)
  }
  let scattered = ray(rec.p, direction)
  Some((attenuation, scattered))
}

fn reflectance(cosine : Double, refraction_index : Double) -> Double {
  // Use Schlick's approximation for reflectance. 
  let mut r0 = (1.0 - refraction_index) / (1.0 + refraction_index)
  r0 *= r0
  r0 + (1.0 - r0) * pow(1.0 - cosine, 5)
}
