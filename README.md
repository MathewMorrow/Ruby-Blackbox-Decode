# Ruby-Blackbox-Decode  

This is a MATLAB program to decode raw binary data log files from my own fully self built quadcopter FPV flight hardware and firmware.  

[**See this repo for an explanation of the blackbox logging firmware**](https://github.com/MathewMorrow/STM32-SD-Logging-DMA.git)

**Link to my FPV drone hardware and Firmware project - THIS REPO IS PRIVATE AT THIS TIME**  
[**RubyFlight Project**](https://github.com/MathewMorrow/rubyflight.git/)  
This hardware+firmware project represent 500+ hours of my time outside of my day job as a Sr. Electrical Eng.  
Once I have more thoroughly documented and cleaned up the project I will make it public.
 
## Background preamble
The simplest way to write data to log file is .csv format. After opening a new file the first row entry can be a CSV header and subsequent data logs will be written for each column.
This method allows for easy data analysis in excel, google-sheets or even a text editor with no decoding required.
The downside to this method is that the data written to the .csv file is not the original INT/UINT/FLOAT **it is an ASCII representation of the number** which means the MCU writing the data to the storage device need to convert every number being logged to an ASCII representation of the number. Not only does this take a significant number of clock cycles to complete it also takes A LOT more memory on the storage device eg. a uint16_t of 2 bytes can take up to 5 bytes in ASCII form and an float... just don't log floats unless absolutely necessary.

The alternative is to log raw binary (the original INT/UINT) values to the log file. However, when you open up the file in you text editor of choice you will be greeted with...

þ|ÿÕSOF ºóA     ÿþÿþ  ÿÏÿÙ  ÿýÿã        þ{ÿÕSOF ºõº     ÿÿ  ÿÓÿÕ  ÿøÿãÿý    þzÿÕSOF ºø2         
ÿâÿÕ  ÿóÿãÿø      þyÿÕSOF ºú«         ÿòÿÙ  ÿðÿãÿòÿý ÿþ þxÿÕSOF ºý&ÿÿ   ÿõ    ÿýÿà  ÿòÿãÿï  ÿü   

This is because the bytes in the file are not ASCII chars that the text editor or CSV editor are expecting.  
The only way to get the data from the log file is extract each raw BYTE/INT/UINT using a decoder that knows exactly the order and format of each piece of data in the log file.

## How the code works 

**File Header**  
* It's nice to have some human readable text at the beginning of a file, such as PID gain, filter cutoffs, that can be quickly checked and compared to other log files without having to decode every time.  
* When I first power on my drone I don't care if it takes 10ms, 50ms or even 100ms to write an ASCII header file with information about by drone settings.
* After the all of the header data is written I write a new line that represent the end of the header "$$ end of header"
* The decoder reads through every line until it reaches the "$$ end of header" and pulls out metadata and other information about the file/drone that will be used later.
```
pitch_PID: 0.002800 0.002800 0.000018  
roll_PID_gain: 0.900000  
yaw_PI: 0.004000  0.004000  
gyro_lpf1: 100  
gyro_notch_hz: 160  
...  
...  
$$ end of header 
```

**Raw Data**
* Every new frame is started with a start-of-frame indicator.
    * This can be as simple as a single char/byte but should be at least two or three chars/bytes to reduce the chances of erroneous SOF flags.
    * I decided to use 3 bytes representing the chars 'SOF'.
* After the 'SOF' marker, the decoder is hard coded to know exactly what data type, scaling and order every value is in the entire frame.
    * The first value is always the timestamp of the data in microseconds since power on.
* The decoder pulls out every value in the frame, scales it appropriately and puts it into shadow register.
```
'SOF'UINT32INT16INT16INT16UINT16UINT16......'SOF'
```

**Data Integrity**
* Before appending the data to an array of timestamped logs, the decoder immediately checks if the next 'SOF' marker is found.
    * If it is found, the data is appended to the working array of data.
    * If not found, the data is thrown away and the file pointer is moved back to the END of the last 'SOF' marker and it read the file until the next 'SOF' is found.
    * For each case a counter is incremented for good frames and bad frames -- I was shocked by the results.
 
**Results**
* Near perfect binary data logging. An 11 minute, 45Mb log of 1,046,638 successful frames decoded with 0 failed frames.
* The pessimist might think "well your code might not be correctly catching fails frames".
    * Rarely but sometimes even on a 2 minute flight there may be 1-2 failed frames out of ~200k.
```
>> logInfo  
logInfo =  
  struct with fields:  
        FileSize: 45005714
        Duration: 662.757986
        NumFrames: 1046638
        FailedFrames: 0
        DecodeTime: 51.3109415
```

# In Action  
## Pitch Rate for 5 minute flight in degrees/sec  
* Red: Raw gyro data
* Blue: Filtered gyro data
* Green: Commanded setpoint to track  
![5minFlight](https://github.com/MathewMorrow/Ruby-Blackbox-Decode/assets/50677844/a7af29ce-427d-47b8-9fb7-9bd96efb57f2)
![5minFlightzoom](https://github.com/MathewMorrow/Ruby-Blackbox-Decode/assets/50677844/114c578f-43c7-4fb6-835f-9ea55d6b3864)
![5minFlight1Sec](https://github.com/MathewMorrow/Ruby-Blackbox-Decode/assets/50677844/a4e7c1d3-0f31-44f3-8d4f-863c1349ce18)
## Roll PID Outputs
![rollPID](https://github.com/MathewMorrow/Ruby-Blackbox-Decode/assets/50677844/cf8a9971-abe0-4901-8f7f-a601b3a4cf9c)
![rollPIDzoom](https://github.com/MathewMorrow/Ruby-Blackbox-Decode/assets/50677844/13e5bfc5-9dd0-4696-9636-b11b197d40cb)

## FFT Application
The most important application for this data logging was FFT analysis to see where to place my LPF and Notch filters on my drone.  
Below is an FFT plot of the raw gyro data from a BMI270 chip and my filtered data going into the PIDs.  
**Anything above ~100Hz needs filtering out and below 80Hz is what the drone needs to control**
![FFT_Example](https://github.com/MathewMorrow/Ruby-Blackbox-Decode/assets/50677844/ac87bff9-3b18-44db-9e1a-0ffdbf506306)






