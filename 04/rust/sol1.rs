use std::io::{self, BufRead};

#[derive(Debug)]
enum Hgt {
    Cm(u8),
    In(u8),
}

impl Hgt {
    fn valid (&self) -> bool {
        match self {
            Hgt::Cm(n) => { n >= &150 && n <= &193 }
            Hgt::In(n) => { n >= &59 && n <= &76 }
        }
    }
}

#[derive(Debug)]
struct Hcl(String);

impl Hcl {
    fn valid (&self) -> bool {
        let Hcl(hcl) = self;

        if !(hcl.len() == 7) { return false; }

        for (i, chr) in hcl.chars().enumerate() {
            if i == 0 {
                if chr != '#' { return false; }
            } else {
                if !('a' <= chr && chr <= 'f') && !('0' <= chr && chr <= '9') { return false; }
            }
        }

        true
    }
}

#[derive(Debug)]
struct Ecl(String);

impl Ecl {
    fn valid (&self) -> bool {
        let Ecl(ecl) = self;
        &"amb" == ecl ||
        &"blu" == ecl ||
        &"brn" == ecl ||
        &"gry" == ecl ||
        &"grn" == ecl ||
        &"hzl" == ecl ||
        &"oth" == ecl
    }
}

#[derive(Debug)]
struct Pid(String);

impl Pid {
    fn valid (&self) -> bool {
        let Pid(hcl) = self;

        if !(hcl.len() == 9) { return false; }

        for chr in hcl.chars() {
            if !('0' <= chr && chr <= '9') { return false; }
        }

        true
    }
}

#[derive(Debug)]
struct Passport {
    byr: u32,
    iyr: u32,
    eyr: u32,
    hgt: Hgt,
    hcl: Hcl,
    ecl: Ecl,
    pid: Pid,
}

impl Passport {
    fn valid (&self) -> bool {
           self.byr >= 1920 && self.byr <= 2002
        && self.iyr >= 2010 && self.iyr <= 2020
        && self.eyr >= 2020 && self.eyr <= 2030
        && self.hgt.valid()
        && self.hcl.valid()
        && self.ecl.valid()
        && self.pid.valid()
    }
}

fn find_field<'a> (name : &str, scratch : &'a Vec<String>) -> Option<&'a str> {
    for line in scratch {
        for field in line.split(' ') {
            if name == &field[0..3] {
                return Some(&field[4..]);
            }
        }
    }

    None
}

fn parse_passport (scratch : &Vec<String>) -> Option<Passport> {
    let byr : u32 = find_field(&"byr", &scratch)?.parse().ok()?;
    let iyr : u32 = find_field(&"iyr", &scratch)?.parse().ok()?;
    let eyr : u32 = find_field(&"eyr", &scratch)?.parse().ok()?;

    let hgt : &str = find_field(&"hgt", &scratch)?;
    let boundary = hgt.len() - 2;
    let hgt : Hgt =
        if &hgt[boundary..] == "in" {
            Hgt::In(hgt[0..boundary].parse().ok()?)
        } else {
            Hgt::Cm(hgt[0..boundary].parse().ok()?)
        };

    let hcl : Hcl = Hcl(String::from(find_field(&"hcl", &scratch)?));
    let ecl : Ecl = Ecl(String::from(find_field(&"ecl", &scratch)?));
    let pid : Pid = Pid(String::from(find_field(&"pid", &scratch)?));

    Some(Passport { byr, iyr, eyr, hgt, hcl, ecl, pid })
}

pub fn main () -> () {
    let mut passports : Vec<Passport> = vec![];

    let mut scratch : Vec<String> = vec![];
    for m_line in io::stdin().lock().lines() {
        if let Ok(line) = m_line {
            if line.len() == 0 {
                if let Some(passport) = parse_passport(&scratch) {
                    if passport.valid() {
                        passports.push(passport);
                    }
                }

                scratch = vec![];
            } else {
                scratch.push(line);
            }
        }
    }

    println!["{}", passports.len()];

    return ();
}
