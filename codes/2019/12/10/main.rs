mod dht11;

const GPIO_DATA: u8 = 2;

fn main() {
    let mut dht11 = dht11::DHT11::new(GPIO_DATA);
    loop {
        match dht11.read() {
            Ok(result) => println!(
                "Temp: {}C, Hum: {}%, Parity: {}",
                result.temperature, result.humidity, result.parity
            ),
            Err(err) => eprintln!("{}", err),
        }
        std::thread::sleep(std::time::Duration::from_secs(2));
    }
}
