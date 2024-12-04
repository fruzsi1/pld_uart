use serialport;
use std::time::Duration;
use std::env;

fn main() {
    
    let args: Vec<String> = env::args().collect();

   //open and configure port 
   let mut port = serialport::new("/dev/ttyUSB0", 115_200)
    .timeout(Duration::from_millis(10))
    .open().expect("Failed to open port");

    //write to port
    let output = args[1].as_bytes();
    port.write(output).expect("Write failed!");

    //wait for response
    //std::thread::sleep(Duration::from_millis(5000));

    //read from port
    let mut serial_buf: Vec<u8> = vec![0; 1024];

    // Read the data into the buffer
    let bytes_read = port.read(&mut serial_buf).expect("Failed to read from serial port");

    // Convert the bytes to a String if the data is valid UTF-8
    let serial_data = String::from_utf8_lossy(&serial_buf[..bytes_read]);

    println!("Read data: {}", serial_data);
    }
